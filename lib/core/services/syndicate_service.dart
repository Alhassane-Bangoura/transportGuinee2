import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SyndicateService {
  static final _supabase = Supabase.instance.client;

  /// Vérifie si un trajet est déjà géré par un syndicat
  static Future<bool> isRouteAvailable(String routeId) async {
    final response = await _supabase
        .from('syndicate_routes')
        .select('id')
        .eq('route_id', routeId)
        .maybeSingle();
    
    return response == null;
  }

  /// Récupère la liste des trajets d'une gare avec leur statut de disponibilité
  static Future<List<Map<String, dynamic>>> getStationRoutesWithAvailability(String stationId) async {
    // 1. Récupérer tous les trajets de la gare
    final routesResponse = await _supabase
        .from('routes')
        .select('id, name')
        .eq('departure_station_id', stationId);
    
    // 2. Récupérer les trajets déjà assignés à des syndicats
    final assignedRoutesResponse = await _supabase
        .from('syndicate_routes')
        .select('route_id');
    
    final Set<String> assignedRouteIds = (assignedRoutesResponse as List)
        .map((r) => r['route_id'] as String)
        .toSet();

    return (routesResponse as List).map((r) {
      final String id = r['id'];
      return {
        'id': id,
        'name': r['name'],
        'isAvailable': !assignedRouteIds.contains(id),
      };
    }).toList();
  }

  /// Assigne des trajets à un syndicat (après vérification d'unicité)
  static Future<void> assignRoutesToSyndicate(String syndicateId, List<String> routeIds) async {
    // La contrainte UNIQUE en DB protégera en cas de conflit concurrent,
    // mais on injecte les lignes ici.
    final List<Map<String, dynamic>> data = routeIds.map((rid) => {
      'syndicate_id': syndicateId,
      'route_id': rid,
    }).toList();

    await _supabase.from('syndicate_routes').insert(data);
  }

  /// 1. & 2. & 3. Récupère les trajets gérés par le syndicat connecté EN TEMPS RÉEL
  static Stream<List<Map<String, dynamic>>> getSyndicateTripsStream() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return const Stream.empty();

    return _supabase
        .from('trips')
        .stream(primaryKey: ['id'])
        .neq('status', 'completed')
        .asyncMap((_) async {
          // Utilisation de auth.uid() via le client pour récupérer les routes autorisées
          final routesRes = await _supabase
              .from('syndicate_routes')
              .select('route_id')
              .eq('syndicate_id', userId);
              
          final routeIds = (routesRes as List).map((r) => r['route_id']).toList();

          if (routeIds.isEmpty) return [];

          final trips = await _supabase
              .from('trips')
              .select('*, profiles:driver_id(full_name, phone), vehicles:vehicle_id(license_plate, type), routes:route_id(departure_city:departure_city_id(name), arrival_city:arrival_city_id(name))')
              .inFilter('route_id', routeIds)
              .neq('status', 'completed')
              .order('departure_time', ascending: true);

          return List<Map<String, dynamic>>.from(trips);
        });
  }

  /// 1. Récupère la liste unique des chauffeurs liés aux trajets du syndicat connecté
  static Future<List<Map<String, dynamic>>> getSyndicateDrivers() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final routesRes = await _supabase
        .from('syndicate_routes')
        .select('route_id')
        .eq('syndicate_id', userId);
        
    final routeIds = (routesRes as List).map((r) => r['route_id']).toList();

    if (routeIds.isEmpty) return [];

    final trips = await _supabase
        .from('trips')
        .select('driver_id, profiles:driver_id(id, full_name, phone, avatar_url), vehicles:vehicle_id(license_plate, type)')
        .inFilter('route_id', routeIds)
        .not('driver_id', 'is', null);

    final Map<String, Map<String, dynamic>> uniqueDrivers = {};
    for (var trip in (trips as List)) {
      final driver = trip['profiles'];
      if (driver != null && !uniqueDrivers.containsKey(driver['id'])) {
        uniqueDrivers[driver['id']] = {
          ...driver,
          'vehicle': trip['vehicles'],
        };
      }
    }

    return uniqueDrivers.values.toList();
  }

  /// 4. & 5. Valider le départ via une procédure stockée sécurisée (RPC)
  /// Cette fonction gère l'autorisation, la mise à jour et la notification côté serveur.
  static Future<bool> validateDeparture(String tripId) async {
    try {
      // Appel de la fonction RPC sécurisée
      // p_trip_id est le paramètre attendu par la fonction validate_trip_departure
      final response = await _supabase.rpc(
        'validate_trip_departure',
        params: {'p_trip_id': tripId},
      );

      return response as bool;
    } catch (e) {
      debugPrint('Error validating departure: $e');
      return false;
    }
  }
}

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
}

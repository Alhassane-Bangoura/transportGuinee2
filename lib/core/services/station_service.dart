import 'package:supabase_flutter/supabase_flutter.dart';

class StationService {
  static final _supabase = Supabase.instance.client;

  /// Récupère le nombre de syndicats rattachés à une gare
  /// Récupère le nombre de syndicats rattachés à une gare
  static Future<int> getSyndicateCount(int stationId) async {
    final response = await _supabase
        .from('profiles')
        .select('id')
        .eq('role', 'SYNDICAT')
        .eq('station_id', stationId);
    return (response as List).length;
  }

  /// Récupère le nombre de chauffeurs rattachés à une gare
  static Future<int> getDriverCount(int stationId) async {
    final response = await _supabase
        .from('profiles')
        .select('id')
        .eq('role', 'CHAUFFEUR')
        .eq('station_id', stationId);
    return (response as List).length;
  }

  /// Récupère le nombre de départs prévus pour une gare
  static Future<int> getDepartureCount(int stationId) async {
    final response = await _supabase
        .from('trips')
        .select('id, routes!inner(departure_city_id)') // In standard schema stations are linked to cities or specific IDs
        // Assuming trips are linked to routes which are linked to stations or departure_station_id
        .eq('status', 'scheduled')
        .eq('routes.departure_station_id', stationId);

    return (response as List).length;
  }

  /// Récupère les véhicules d'une gare
  static Future<List<Map<String, dynamic>>> getStationVehicles(int stationId) async {
    // Vehicles are linked to syndicates/drivers which are linked to stations
    final response = await _supabase
        .from('vehicles')
        .select('*, profiles!syndicate_id(station_id), driver:profiles!driver_id(full_name)')
        .eq('profiles.station_id', stationId);

    return (response as List).map((v) => {
      'id': v['id'],
      'license_plate': v['license_plate'],
      'model': v['model'] ?? 'Standard',
      'capacity': v['capacity'],
      'driver_name': v['driver']?['full_name'] ?? 'Non assigné',
      'status': 'Disponible',
    }).toList();
  }

  /// Récupère les quais (quais) d'une gare
  static Future<List<Map<String, dynamic>>> getStationPlatforms(int stationId) async {
    // If you have a separate platforms table, use it. Otherwise, derive from station/trips
    // Assume station has platforms or we derive from ongoing trips
    final response = await _supabase
        .from('trips')
        .select('quay_number, status, routes!inner(departure_station_id)')
        .eq('routes.departure_station_id', stationId)
        .not('quay_number', 'is', null);

    final Map<int, Map<String, dynamic>> platforms = {};
    for (var item in (response as List)) {
      final quay = item['quay_number'] as int?;
      if (quay != null && !platforms.containsKey(quay)) {
        platforms[quay] = {
          'number': quay.toString(),
          'status': item['status'] == 'boarding' ? 'OCCUPÉ' : 'LIBRE',
          'isOccupied': item['status'] == 'boarding',
        };
      }
    }
    return platforms.values.toList();
  }

  /// Récupère les syndicats d'une gare avec leur statut de relais
  static Future<List<Map<String, dynamic>>> getStationSyndicates(int stationId) async {
    try {
      // On tente d'utiliser la vue de relais si elle existe
      final response = await _supabase
          .from('vw_syndicate_relay_status')
          .select('*')
          .eq('station_id', stationId);

      return (response as List).map((s) => {
        'id': s['syndicate_id'],
        'name': s['full_name'],
        'driver_count': s['driver_count'] ?? 0,
        'last_activity': s['last_activity'],
        'status': s['is_active_status'] == true ? 'Actif' : 'Inactif',
        'is_active': s['is_active_status'] == true,
      }).toList();
    } catch (e) {
      // Fallback si la vue n'est pas encore créée
      final response = await _supabase
          .from('profiles')
          .select('*')
          .eq('role', 'SYNDICAT')
          .eq('station_id', stationId);

      return (response as List).map((s) => {
        'id': s['id'],
        'name': s['full_name'],
        'status': s['is_active'] == false ? 'Inactif' : 'Actif',
        'is_active': s['is_active'] != false,
      }).toList();
    }
  }

  /// Récupère le nombre de syndicats inactifs (pour le badge dashboard)
  static Future<int> getInactiveSyndicateCount(int stationId) async {
    try {
      final response = await _supabase
          .from('vw_syndicate_relay_status')
          .select('syndicate_id')
          .eq('station_id', stationId)
          .eq('is_active_status', false);
      return (response as List).length;
    } catch (_) {
      return 0;
    }
  }

  /// Récupère le nombre de chauffeurs sans syndicat (en attente)
  static Future<int> getUnassignedDriverCount(int stationId) async {
    final response = await _supabase
        .from('profiles')
        .select('id')
        .eq('role', 'CHAUFFEUR')
        .eq('station_id', stationId)
        .isFilter('syndicate_id', null);
    return (response as List).length;
  }

  /// Récupère la liste des chauffeurs sans syndicat
  static Future<List<Map<String, dynamic>>> getUnassignedDrivers(int stationId) async {
    final response = await _supabase
        .from('profiles')
        .select('*, routes(name)')
        .eq('role', 'CHAUFFEUR')
        .eq('station_id', stationId)
        .isFilter('syndicate_id', null);

    return (response as List).map((d) => {
      'id': d['id'],
      'name': d['full_name'],
      'phone': d['phone'],
      'route_name': d['routes']?['name'] ?? 'Non spécifié',
      'created_at': d['created_at'],
    }).toList();
  }
}

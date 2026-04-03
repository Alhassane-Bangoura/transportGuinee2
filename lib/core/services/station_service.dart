import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_response.dart';

class StationService {
  static final _supabase = Supabase.instance.client;

  /// Récupère le nombre de syndicats rattachés à une gare
  static Future<AppResponse<int>> getSyndicateCount(String stationId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('id')
          .eq('role', 'SYNDICAT')
          .eq('station_id', stationId);
      return AppResponse.success((response as List).length);
    } catch (e) {
      debugPrint('Error getting syndicate count: $e');
      return AppResponse.failure('Impossible de charger le nombre de syndicats.');
    }
  }

  /// Récupère le nombre de chauffeurs rattachés à une gare
  static Future<AppResponse<int>> getDriverCount(String stationId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('id')
          .eq('role', 'CHAUFFEUR')
          .eq('station_id', stationId);
      return AppResponse.success((response as List).length);
    } catch (e) {
      debugPrint('Error getting driver count: $e');
      return AppResponse.failure('Impossible de charger le nombre de chauffeurs.');
    }
  }

  /// Récupère le nombre de départs prévus pour une gare
  static Future<AppResponse<int>> getDepartureCount(String stationId) async {
    try {
      final response = await _supabase
          .from('trips')
          .select('id, routes!inner(departure_city_id)')
          .eq('status', 'scheduled')
          .eq('routes.departure_station_id', stationId);

      return AppResponse.success((response as List).length);
    } catch (e) {
      debugPrint('Error getting departure count: $e');
      return AppResponse.failure('Impossible de charger le nombre de départs.');
    }
  }

  /// Récupère les véhicules d'une gare
  static Future<AppResponse<List<Map<String, dynamic>>>> getStationVehicles(String stationId) async {
    try {
      final response = await _supabase
          .from('vehicles')
          .select('*, profiles!syndicate_id(station_id), driver:profiles!driver_id(full_name)')
          .eq('profiles.station_id', stationId);

      final vehicles = (response as List).map((v) => {
        'id': v['id'],
        'license_plate': v['license_plate'],
        'model': v['model'] ?? 'Standard',
        'capacity': v['capacity'],
        'driver_name': v['driver']?['full_name'] ?? 'Non assigné',
        'status': 'Disponible',
      }).toList();
      return AppResponse.success(vehicles);
    } catch (e) {
      debugPrint('Error getting station vehicles: $e');
      return AppResponse.failure('Impossible de charger les véhicules de la gare.');
    }
  }

  /// Récupère les quais (quais) d'une gare
  static Future<AppResponse<List<Map<String, dynamic>>>> getStationPlatforms(String stationId) async {
    try {
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
      return AppResponse.success(platforms.values.toList());
    } catch (e) {
      debugPrint('Error getting station platforms: $e');
      return AppResponse.failure('Impossible de charger les quais de la gare.');
    }
  }

  /// Récupère les syndicats d'une gare avec leur statut de relais
  static Future<AppResponse<List<Map<String, dynamic>>>> getStationSyndicates(String stationId) async {
    try {
      try {
        final response = await _supabase
            .from('vw_syndicate_relay_status')
            .select('*')
            .eq('station_id', stationId);

        final syndicates = (response as List).map((s) => {
          'id': s['syndicate_id'],
          'name': s['full_name'],
          'driver_count': s['driver_count'] ?? 0,
          'last_activity': s['last_activity'],
          'status': s['is_active_status'] == true ? 'Actif' : 'Inactif',
          'is_active': s['is_active_status'] == true,
        }).toList();
        return AppResponse.success(syndicates);
      } catch (e) {
        final response = await _supabase
            .from('profiles')
            .select('*')
            .eq('role', 'SYNDICAT')
            .eq('station_id', stationId);

        final syndicates = (response as List).map((s) => {
          'id': s['id'],
          'name': s['full_name'],
          'status': s['is_active'] == false ? 'Inactif' : 'Actif',
          'is_active': s['is_active'] != false,
        }).toList();
        return AppResponse.success(syndicates);
      }
    } catch (e) {
      debugPrint('Error getting station syndicates: $e');
      return AppResponse.failure('Impossible de charger les syndicats de la gare.');
    }
  }

  /// Récupère le nombre de syndicats inactifs (pour le badge dashboard)
  static Future<AppResponse<int>> getInactiveSyndicateCount(String stationId) async {
    try {
      final response = await _supabase
          .from('vw_syndicate_relay_status')
          .select('syndicate_id')
          .eq('station_id', stationId)
          .eq('is_active_status', false);
      return AppResponse.success((response as List).length);
    } catch (_) {
      return AppResponse.success(0);
    }
  }

  /// Récupère le nombre de chauffeurs sans syndicat (en attente)
  static Future<AppResponse<int>> getUnassignedDriverCount(String stationId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('id')
          .eq('role', 'CHAUFFEUR')
          .eq('station_id', stationId)
          .isFilter('syndicate_id', null);
      return AppResponse.success((response as List).length);
    } catch (e) {
      debugPrint('Error getting unassigned driver count: $e');
      return AppResponse.failure('Impossible de charger le nombre de chauffeurs en attente.');
    }
  }

  /// Récupère la liste des chauffeurs sans syndicat
  static Future<AppResponse<List<Map<String, dynamic>>>> getUnassignedDrivers(String stationId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('*, routes(name)')
          .eq('role', 'CHAUFFEUR')
          .eq('station_id', stationId)
          .isFilter('syndicate_id', null);

      final drivers = (response as List).map((d) => {
        'id': d['id'],
        'name': d['full_name'],
        'phone': d['phone'],
        'route_name': d['routes']?['name'] ?? 'Non spécifié',
        'created_at': d['created_at'],
      }).toList();
      return AppResponse.success(drivers);
    } catch (e) {
      debugPrint('Error getting unassigned drivers: $e');
      return AppResponse.failure('Impossible de charger la liste des chauffeurs en attente.');
    }
  }
}

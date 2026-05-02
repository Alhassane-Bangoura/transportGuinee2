import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/city.dart';
import '../models/station.dart';
import '../models/route_model.dart';

class LocationService {
  static final _supabase = Supabase.instance.client;

  /// Récupère toutes les villes
  static Future<List<City>> getCities() async {
    final data = await _supabase.from('cities').select().order('name');
    return (data as List).map((json) => City.fromJson(json)).toList();
  }

  /// Récupère les gares d'une ville
  static Future<List<Station>> getStationsByCity(String cityId) async {
    final data = await _supabase
        .from('stations')
        .select()
        .eq('city_id', cityId)
        .order('name');
    return (data as List).map((json) => Station.fromJson(json)).toList();
  }

  /// Récupère les gares (toutes)
  static Future<List<Station>> getAllStations() async {
    final data = await _supabase.from('stations').select().order('name');
    return (data as List).map((json) => Station.fromJson(json)).toList();
  }

  /// Récupère les trajets (routes) d'une ville (ou gare)
  /// Récupère les trajets (routes) d'une gare (avec fallback ville)
  static Future<List<RouteModel>> getRoutesByStation(String stationId, {String? cityId}) async {
    try {
      // 1. Essayer par GARE d'abord (plus précis)
      var data = await _supabase
          .from('routes')
          .select('''
            *,
            departure_city:cities!departure_city_id(name),
            arrival_city:cities!arrival_city_id(name)
          ''')
          .eq('departure_station_id', stationId);

      // 2. Si vide et qu'on a un cityId, essayer par VILLE (moins précis)
      if ((data as List).isEmpty && cityId != null) {
        data = await _supabase
            .from('routes')
            .select('''
              *,
              departure_city:cities!departure_city_id(name),
              arrival_city:cities!arrival_city_id(name)
            ''')
            .eq('departure_city_id', cityId);
      }

      debugPrint('[LocationService] Fetched ${data.length} routes for station $stationId (Fallback city: $cityId)');

      return (data as List).map((json) {
        return RouteModel(
          id: json['id'] as String,
          departureStationId: json['departure_station_id'] as String? ?? '',
          arrivalStationId: json['arrival_station_id'] as String? ?? '',
          departureStationName: json['departure_city']?['name'] as String?,
          arrivalStationName: json['arrival_city']?['name'] as String?,
          arrivalCityName: json['arrival_city']?['name'] as String?,
          arrivalCityId: json['arrival_city_id'] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint('[LocationService] Error fetching routes: $e');
      return [];
    }
  }
}

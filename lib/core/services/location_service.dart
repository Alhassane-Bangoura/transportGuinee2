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

  /// Récupère les trajets (routes) d'une gare de départ
  static Future<List<RouteModel>> getRoutesByStation(String stationId) async {
    try {
      final data = await _supabase
          .from('routes')
          .select('''
            *,
            departure_station:stations!departure_station_id(name),
            arrival_station:stations!arrival_station_id(
              name, 
              city:cities!city_id(name)
            )
          ''')
          .eq('departure_station_id', stationId);

      debugPrint('[LocationService] Fetched ${data.length} routes for station $stationId');

      return (data as List).map((json) {
        final arrivalStation = json['arrival_station'];
        final arrivalCity = arrivalStation != null ? arrivalStation['city'] : null;
        
        return RouteModel(
          id: json['id'] as String,
          departureStationId: json['departure_station_id'] as String,
          arrivalStationId: json['arrival_station_id'] as String,
          departureStationName: json['departure_station']['name'] as String?,
          arrivalStationName: arrivalStation?['name'] as String?,
          arrivalCityName: arrivalCity?['name'] as String?,
          arrivalCityId: json['arrival_city_id'] as String?,
          syndicateId: json['syndicate_id'] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint('[LocationService] Error fetching routes: $e');
      return [];
    }
  }
}

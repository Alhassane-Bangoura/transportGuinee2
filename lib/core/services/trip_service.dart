import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/trip.dart';
import '../utils/app_response.dart';

// ============================================================================
// TripService — Gestion des trajets via Supabase
// ============================================================================

class TripService {
  static final _supabase = Supabase.instance.client;

  // ─── Recherche de trajets ────────────────────────────────────────────────

  /// Recherche des trajets disponibles via la vue 'trips_with_details'
  static Future<AppResponse<List<Trip>>> searchTrips({
    required String departureCityName,
    required String arrivalCityName,
    DateTime? date,
  }) async {
    try {
      var query = _supabase
          .from('trips_with_details')
          .select()
          .eq('departure_city_name', departureCityName)
          .eq('arrival_city_name', arrivalCityName);

      if (date != null) {
        final start = DateTime(date.year, date.month, date.day).toIso8601String();
        final end = DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();
        query = query.gte('departure_time', start).lte('departure_time', end);
      }

      final data = await query;
      final trips = (data as List).map((t) => Trip.fromJson(t)).toList();
      return AppResponse.success(trips);
    } catch (e) {
      debugPrint('Error searching trips: $e');
      return AppResponse.failure('Erreur lors de la recherche des trajets.');
    }
  }

  /// Récupère les prochains trajets disponibles (optionnellement pour une gare précise)
  static Future<AppResponse<List<Trip>>> getUpcomingTrips({int limit = 5, String? stationId}) async {
    try {
      var query = _supabase
          .from('trips_with_details')
          .select()
          .gte('departure_time', DateTime.now().toIso8601String());
      
      if (stationId != null) {
        query = query.eq('departure_station_id', stationId);
      }

      final data = await query.order('departure_time').limit(limit);
      final trips = (data as List).map((t) => Trip.fromJson(t)).toList();
      return AppResponse.success(trips);
    } catch (e) {
      debugPrint('Error getting upcoming trips: $e');
      return AppResponse.failure('Impossible de charger les prochains trajets.');
    }
  }

  // ─── Trajets par Chauffeur ───────────────────────────────────────────────

  /// Récupère les trajets d'un chauffeur en temps réel
  static Stream<List<Trip>> getDriverTripsStream(String driverId) {
    return _supabase
        .from('trips_with_details')
        .stream(primaryKey: ['id'])
        .eq('driver_id', driverId)
        .order('departure_time', ascending: true)
        .map((data) => data.map((t) => Trip.fromJson(t)).toList());
  }

  // ─── Détail d'un trajet ──────────────────────────────────────────────────

  static Future<AppResponse<Trip>> getTripById(String tripId) async {
    try {
      final data = await _supabase
          .from('trips_with_details')
          .select()
          .eq('id', tripId)
          .single();
      return AppResponse.success(Trip.fromJson(data));
    } on PostgrestException catch (e) {
      debugPrint('Supabase error getting trip: ${e.message}');
      return AppResponse.failure('Trajet introuvable.');
    } catch (e) {
      debugPrint('Unexpected error getting trip: $e');
      return AppResponse.failure('Une erreur est survenue lors du chargement du trajet.');
    }
  }

  // ─── Mise à jour de trajet ──────────────────────────────────────────────

  /// Met à jour le statut d'un trajet (Normal ou Relais Admin)
  static Future<AppResponse<void>> updateTripStatus(String tripId, String newStatus) async {
    try {
      await _supabase
          .from('trips')
          .update({'status': newStatus, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', tripId);
      return AppResponse.success(null);
    } catch (e) {
      debugPrint('Error updating trip status: $e');
      return AppResponse.failure('Échec de la mise à jour du statut du trajet.');
    }
  }
}

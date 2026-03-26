import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/trip.dart';

// ============================================================================
// TripService — Gestion des trajets via Supabase
// ============================================================================

class TripService {
  static final _supabase = Supabase.instance.client;

  // ─── Recherche de trajets ────────────────────────────────────────────────

  /// Recherche des trajets disponibles via la vue 'trips_with_details'
  static Future<List<Trip>> searchTrips({
    required String departureCityName,
    required String arrivalCityName,
    DateTime? date,
  }) async {
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
    return (data as List).map((t) => Trip.fromJson(t)).toList();
  }

  /// Récupère les prochains trajets disponibles (optionnellement pour une gare précise)
  static Future<List<Trip>> getUpcomingTrips({int limit = 5, int? stationId}) async {
    var query = _supabase
        .from('trips_with_details')
        .select()
        .gte('departure_time', DateTime.now().toIso8601String());
    
    if (stationId != null) {
      query = query.eq('departure_station_id', stationId);
    }

    final data = await query.order('departure_time').limit(limit);
    
    return (data as List).map((t) => Trip.fromJson(t)).toList();
  }

  // ─── Détail d'un trajet ──────────────────────────────────────────────────

  static Future<Trip?> getTripById(int tripId) async {
    try {
      final data = await _supabase
          .from('trips_with_details')
          .select()
          .eq('id', tripId)
          .single();
      return Trip.fromJson(data);
    } catch (_) {
      return null;
    }
  }
  // ─── Mise à jour de trajet ──────────────────────────────────────────────

  /// Met à jour le statut d'un trajet (Normal ou Relais Admin)
  static Future<bool> updateTripStatus(String tripId, String newStatus) async {
    try {
      await _supabase
          .from('trips')
          .update({'status': newStatus, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', tripId);
      return true;
    } catch (e) {
      debugPrint('Error updating trip status: $e');
      return false;
    }
  }
}

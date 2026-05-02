import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/trip.dart';
import '../utils/app_response.dart';
import 'notification_service.dart';

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
          .ilike('departure_city_name', departureCityName.trim())
          .ilike('arrival_city_name', arrivalCityName.trim());

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

  static List<Trip> _cachedDriverTrips = [];
  static String? _lastDriverId;

  /// Réinitialise les caches pour éviter les fuites de données entre utilisateurs
  static void clearCache() {
    _cachedDriverTrips = [];
    _lastDriverId = null;
    debugPrint('[TripService] Cache cleared');
  }

  /// Récupère les trajets d'un chauffeur en temps réel
  static Stream<List<Trip>> getDriverTripsStream(String driverId) {
    // Isolation du cache par chauffeur
    if (_lastDriverId != driverId) {
      _cachedDriverTrips = [];
      _lastDriverId = driverId;
    }

    return _supabase
        .from('trips')
        .stream(primaryKey: ['id'])
        .eq('driver_id', driverId)
        .asyncMap((_) async {
          try {
            debugPrint('[TripService] FETCHING DRIVER TRIPS FROM DB for driver $driverId...');
            final res = await _supabase
              .from('trips_with_details')
              .select()
              .eq('driver_id', driverId)
              .order('departure_time', ascending: true);
            _cachedDriverTrips = (res as List).map((t) => Trip.fromJson(t)).toList();
            
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('cache_driver_trips_$driverId', jsonEncode(_cachedDriverTrips.map((e) => e.toJson()).toList()));
            return _cachedDriverTrips;
          } catch (e) {
            if (_cachedDriverTrips.isEmpty) {
              final prefs = await SharedPreferences.getInstance();
              final cachedStr = prefs.getString('cache_driver_trips_$driverId');
              if (cachedStr != null) {
                try {
                  final List<dynamic> decoded = jsonDecode(cachedStr);
                  _cachedDriverTrips = decoded.map((e) => Trip.fromJson(e)).toList();
                } catch (_) {}
              }
            }
            return _cachedDriverTrips;
          }
        });
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

  // ─── Création de trajet ──────────────────────────────────────────────────

  /// Publie un nouveau trajet
  static Future<AppResponse<void>> publishTrip(Map<String, dynamic> tripData) async {
    try {
      debugPrint('[TripService] Publishing trip data: $tripData');

      // Insertion directe en 'scheduled' après correction du trigger ON CONFLICT DO NOTHING.
      // Les notifications aux passagers sont gérées automatiquement par le trigger trg_notify_on_new_trip.
      final cleanData = {
        ...tripData,
        'status': 'scheduled',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('trips').insert(cleanData);

      return AppResponse.success(null);
    } on PostgrestException catch (e) {
      debugPrint('[TripService] CRITICAL EXCEPTION: ${e.message}');
      debugPrint('[TripService] CODE: ${e.code}');
      debugPrint('[TripService] DETAILS: ${e.details}');
      debugPrint('[TripService] HINT: ${e.hint}');
      return AppResponse.failure('Erreur de base de données : ${e.message} (${e.code})');
    } catch (e) {
      debugPrint('[TripService] Unexpected error: $e');
      return AppResponse.failure(e.toString());
    }
  }

  // ─── Routes ──────────────────────────────────────────────────────────────

  /// Récupère les détails d'une route par son ID
  static Future<AppResponse<Map<String, dynamic>>> getRouteById(String routeId) async {
    try {
      final data = await _supabase
          .from('routes')
          .select('id, name, departure_city:departure_city_id(id, name), arrival_city:arrival_city_id(id, name)')
          .eq('id', routeId)
          .single();
      return AppResponse.success(data);
    } catch (e) {
      debugPrint('Error getting route: $e');
      return AppResponse.failure(e.toString());
    }
  }

  /// Supprime un trajet (Seulement s'il n'y a aucune réservation)
  static Future<AppResponse<void>> deleteTrip(String tripId) async {
    try {
      // 1. Vérifier s'il y a des réservations
      final bookingsRes = await _supabase
          .from('bookings')
          .select('id')
          .eq('trip_id', tripId)
          .filter('status', 'not.ilike', 'cancelled')
          .limit(1);
          
      if ((bookingsRes as List).isNotEmpty) {
        return AppResponse.failure('Impossible de supprimer : ce trajet a déjà des réservations.');
      }

      // 2. Si aucune réservation, supprimer
      await _supabase.from('trips').delete().eq('id', tripId);
      
      return AppResponse.success(null);
    } catch (e) {
      debugPrint('Error deleting trip: $e');
      return AppResponse.failure('Erreur lors de la suppression du trajet.');
    }
  }
}

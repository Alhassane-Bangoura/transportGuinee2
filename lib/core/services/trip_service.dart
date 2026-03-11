import 'dart:async';
import '../models/trip.dart';
import 'mock_data.dart';

// ============================================================================
// TripService — Gestion des trajets (MODE DÉMO UNIQUEMENT)
// ============================================================================

class TripService {
  // ─── Recherche de trajets ────────────────────────────────────────────────

  /// Recherche des trajets disponibles (MOCK)
  static Future<List<Trip>> searchTrips({
    required String departureCityName,
    required String arrivalCityName,
    DateTime? date,
  }) async {
    return MockData.trips
        .where((t) =>
            t.departureCityName.toLowerCase() == departureCityName.toLowerCase() &&
            t.arrivalCityName.toLowerCase() == arrivalCityName.toLowerCase())
        .toList();
  }

  /// Récupère les prochains trajets disponibles (MOCK)
  static Future<List<Trip>> getUpcomingTrips({int limit = 5}) async {
    return MockData.trips.take(limit).toList();
  }

  // ─── Détail d'un trajet ──────────────────────────────────────────────────

  static Future<Trip?> getTripById(String tripId) async {
    try {
      return MockData.trips.firstWhere((t) => t.id == tripId);
    } catch (_) {
      return null;
    }
  }

  /// Récupère toutes les villes disponibles (MOCK)
  static Future<List<String>> getCityNames() async {
    return MockData.trips
        .map((t) => t.departureCityName)
        .toSet()
        .toList()
      ..addAll(MockData.trips.map((t) => t.arrivalCityName))
      ..sort();
  }
}

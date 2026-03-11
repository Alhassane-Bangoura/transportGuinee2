import 'dart:async';
import '../models/booking.dart';
import 'mock_data.dart';

// ============================================================================
// BookingService — Gestion des réservations (MODE DÉMO UNIQUEMENT)
// ============================================================================

class BookingService {
  // ─── Réservations de l'utilisateur ──────────────────────────────────────

  /// Récupère toutes les réservations de l'utilisateur (MOCK)
  static Future<List<Booking>> getUserBookings() async {
    return MockData.bookings;
  }

  /// Crée une nouvelle réservation (MOCK)
  static Future<Booking> createBooking({
    required String tripId,
    required int seats,
    List<int>? selectedSeats,
    required double totalPrice,
  }) async {
    final newBooking = Booking(
      id: 'booking-${DateTime.now().millisecondsSinceEpoch}',
      tripId: tripId,
      userId: 'mock-passenger-id',
      seats: seats,
      totalPrice: totalPrice,
      status: 'confirmed',
      createdAt: DateTime.now(),
      departureCityName: 'Recherche...',
      arrivalCityName: 'Dest...',
      departureTime: DateTime.now().add(const Duration(hours: 1)),
    );
    MockData.bookings.add(newBooking);
    return newBooking;
  }

  /// Annule une réservation (MOCK)
  static Future<void> cancelBooking(String bookingId) async {
    try {
      final b = MockData.bookings.firstWhere((element) => element.id == bookingId);
      MockData.bookings.remove(b);
    } catch (_) {}
  }

  /// Génère un billet (MOCK)
  static Future<void> generateTicket(String bookingId) async {
    // Rien à faire en mode mock
  }
}

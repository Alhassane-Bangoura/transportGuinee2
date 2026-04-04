import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking.dart';
import '../utils/app_response.dart';

// ============================================================================
// BookingService — Gestion des réservations (Intégration Supabase Realtime)
// ============================================================================

class BookingService {
  static final _supabase = Supabase.instance.client;

  // ─── Réservations de l'utilisateur ──────────────────────────────────────

  /// Écoute les réservations de l'utilisateur en temps réel (déclenche un refetch complet)
  static Stream<List<Booking>> getUserBookingsStream() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return const Stream.empty();

    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .asyncMap((_) async {
          // Relancer un fetch complet pour avoir toutes les relations
          final response = await getUserBookings();
          return response.data ?? [];
        });
  }

  /// Récupère toutes les réservations de l'utilisateur
  static Future<AppResponse<List<Booking>>> getUserBookings() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return AppResponse.failure('Non connecté');

      final data = await _supabase
          .from('bookings')
          .select('*, trips:trip_id(*, routes:route_id(*, departure_city:departure_city_id(name), arrival_city:arrival_city_id(name), departure_station:departure_station_id(name), arrival_station:arrival_station_id(name))), tickets(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
          
      final bookings = (data as List).map((b) => Booking.fromJson(b)).toList();
      return AppResponse.success(bookings);
    } catch (e) {
      debugPrint('Error getting bookings: $e');
      return AppResponse.failure('Impossible de charger vos réservations.');
    }
  }

  /// Crée une nouvelle réservation
  static Future<AppResponse<Booking>> createBooking({
    required String tripId,
    required int seats,
    List<int>? selectedSeats,
    required double totalPrice,
    required String fromCity,
    required String toCity,
    required DateTime departureDate,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return AppResponse.failure('Non connecté');

      final newBooking = {
        'trip_id': tripId,
        'user_id': userId,
        'seats': seats,
        'selected_seats': selectedSeats ?? [],
        'total_price': totalPrice,
        'status': 'confirmed' // Directement confirmé pour la simulation
      };

      final response = await _supabase
          .from('bookings')
          .insert(newBooking)
          .select('*, trips:trip_id(*, routes:route_id(*, departure_city:departure_city_id(name), arrival_city:arrival_city_id(name), departure_station:departure_station_id(name), arrival_station:arrival_station_id(name))), tickets(*)')
          .single();

      // On insère aussi un faux ticket pour compléter la simulation
      final bookingId = response['id'];
      await _supabase.from('tickets').insert({
        'booking_id': bookingId,
        'qr_code': 'QR_$bookingId',
        'status': 'valid'
      });

      return AppResponse.success(Booking.fromJson(response), message: 'Réservation confirmée avec succès !');
    } catch (e) {
      debugPrint('Error creating booking: $e');
      return AppResponse.failure('Échec de la réservation. Veuillez réessayer. L''erreur: $e');
    }
  }

  /// Annule une réservation
  static Future<AppResponse<void>> cancelBooking(String bookingId) async {
    try {
      await _supabase
          .from('bookings')
          .update({'status': 'cancelled'})
          .eq('id', bookingId);
      return AppResponse.success(null, message: 'Réservation annulée.');
    } catch (e) {
      debugPrint('Error cancelling booking: $e');
      return AppResponse.failure('Impossible d\'annuler la réservation.');
    }
  }

  /// Génère un billet (Mock/Update DB)
  static Future<AppResponse<void>> generateTicket(String bookingId) async {
    try {
      await _supabase.from('tickets').update({'status': 'valid'}).eq('booking_id', bookingId);
      return AppResponse.success(null, message: 'Billet généré avec succès.');
    } catch (e) {
      return AppResponse.failure('Erreur lors de la génération du billet.');
    }
  }

  // ─── Commandes Chauffeur ────────────────────────────────────────────────

  /// Récupère la liste des passagers pour un trajet donné
  static Future<AppResponse<List<Map<String, dynamic>>>> getTripPassengers(String tripId) async {
    try {
      final data = await _supabase
          .from('bookings')
          .select('*, profiles:user_id(full_name, phone), tickets(*)')
          .eq('trip_id', tripId)
          .eq('status', 'confirmed');
      return AppResponse.success(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      debugPrint('Error getting trip passengers: $e');
      return AppResponse.failure('Impossible de charger les passagers.');
    }
  }

  /// Valide un ticket en scannant (Mock/Update DB)
  static Future<AppResponse<void>> validateTicket(String ticketId) async {
    try {
      await _supabase.from('tickets').update({'status': 'used'}).eq('id', ticketId);
      return AppResponse.success(null, message: 'Billet validé avec succès.');
    } catch (e) {
      debugPrint('Error validating ticket: $e');
      return AppResponse.failure('Erreur lors de la validation du billet.');
    }
  }
}

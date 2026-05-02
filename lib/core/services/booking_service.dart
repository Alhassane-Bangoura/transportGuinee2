import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/booking.dart';
import '../utils/app_response.dart';
import '../utils/field_test_logger.dart';
import 'notification_service.dart';

// ============================================================================
// BookingService — Gestion des réservations (Intégration Supabase Realtime)
// ============================================================================

class BookingService {
  static final _supabase = Supabase.instance.client;

  static List<Booking> _cachedUserBookings = [];
  static String? _lastUserId;

  /// Réinitialise les caches (appelé à la déconnexion)
  static void clearCache() {
    _cachedUserBookings = [];
    _lastUserId = null;
    debugPrint('[BookingService] Cache cleared');
  }

  /// Écoute les réservations de l'utilisateur (Simplifié pour éviter les blocages)
  static Stream<List<Booking>> getUserBookingsStream() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return const Stream.empty();

    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .asyncMap((_) async {
          // Si on change d'utilisateur, on vide le cache mémoire
          if (_lastUserId != userId) {
            _cachedUserBookings = [];
            _lastUserId = userId;
          }

          final res = await getUserBookings();
          if (res.isSuccess && res.data != null) {
            _cachedUserBookings = res.data!;
            // Cache local optionnel par utilisateur
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('cache_user_bookings_$userId', jsonEncode(_cachedUserBookings.map((e) => e.toJson()).toList()));
            return _cachedUserBookings;
          }
          
          // Fallback local uniquement si pas de données mémoire et erreur réseau
          if (_cachedUserBookings.isEmpty) {
            final prefs = await SharedPreferences.getInstance();
            final cachedStr = prefs.getString('cache_user_bookings_$userId');
            if (cachedStr != null) {
              try {
                final List<dynamic> decoded = jsonDecode(cachedStr);
                _cachedUserBookings = decoded.map((e) => Booking.fromJson(e)).toList();
              } catch (_) {}
            }
          }
          return _cachedUserBookings;
        });
  }

  /// Récupère toutes les réservations de l'utilisateur
  static Future<AppResponse<List<Booking>>> getUserBookings() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return AppResponse.failure('Non connecté');

      debugPrint('[BookingService] FETCHING BOOKINGS FROM DB for user ${userId}...');
      final data = await _supabase
          .from('bookings')
          .select('*, trips:trip_id(*, driver:driver_id(full_name, phone), routes:route_id(*, departure_city:departure_city_id(name), arrival_city:arrival_city_id(name), departure_station:departure_station_id(name), arrival_station:arrival_station_id(name))), tickets(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
          
      final bookings = (data as List).map((b) => Booking.fromJson(b)).toList();
      debugPrint('[BookingService] ${bookings.length} bookings fetched from DB');
      return AppResponse.success(bookings);
    } catch (e) {
      debugPrint('Error getting bookings: $e');
      return AppResponse.failure('Impossible de charger vos réservations.');
    }
  }

  /// Crée une nouvelle réservation (Adapté pour TEST TERRAIN GUINÉE)
  static Future<AppResponse<Booking>> createBooking({
    required String tripId,
    required int seats,
    List<int>? selectedSeats,
    required double totalPrice,
    required String fromCity,
    required String toCity,
    required DateTime departureDate,
    String paymentMethod = 'at_station',
    String? idempotencyKey, // Reçu de l'UI pour garantir l'idempotence sur les retries
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return AppResponse.failure('Non connecté');
    
    // Générer ou utiliser la clé d'idempotence AVANT le try pour qu'elle soit accessible dans le catch
    final actualIdempotencyKey = idempotencyKey ?? const Uuid().v4();

    try {
      final newBooking = {
        'trip_id': tripId,
        'user_id': userId,
        'seats': seats,
        'total_price': totalPrice,
        'status': 'pending',
      };

      // 1. Insérer la réservation
      final bookingResponse = await _supabase
          .from('bookings')
          .insert(newBooking)
          .select()
          .single();

      final bookingId = bookingResponse['id'];

      try {
        // 2. Génération du ticket initial
        await _supabase.from('tickets').insert({
          'booking_id': bookingId,
          'qr_code': 'QR_$bookingId',
          'status': paymentMethod == 'at_station' ? 'pending_payment' : 'valid'
        });
      } catch (ticketError) {
        // CRITIQUE : Si le ticket échoue, on supprime la réservation pour libérer le siège
        debugPrint('🚨 [BookingService] Ticket creation failed, rolling back booking $bookingId');
        await _supabase.from('bookings').delete().eq('id', bookingId);
        rethrow;
      }

      // 3. Récupération des détails complets
      final finalData = await _supabase
          .from('bookings')
          .select('*, trips:trip_id(*, driver:profiles!driver_id(full_name, phone), routes:route_id(*, departure_city:departure_city_id(name), arrival_city:arrival_city_id(name), departure_station:departure_station_id(name), arrival_station:arrival_station_id(name))), tickets(*)')
          .eq('id', bookingId)
          .single();

      FieldTestLogger.logBooking(userId, tripId, paymentMethod);

      return AppResponse.success(Booking.fromJson(finalData), 
        message: paymentMethod == 'at_station' 
          ? 'Réservation enregistrée. Payez à la gare.' 
          : 'Réservation confirmée !');

    } on PostgrestException catch (e) {
      FieldTestLogger.logError('CREATE_BOOKING_DB', e);
      debugPrint('🚨 [FIELD_TEST] Database Error: ${e.message} (Code: ${e.code})');
      
      // GESTION SPAM NOTIFICATION (Constraint unique_notification_spam)
      if (e.message.contains('unique_notification_spam')) {
        return AppResponse.failure('Conflit de notification : Une notification similaire existe déjà. Veuillez patienter ou changer de trajet.');
      }

      if (e.message.contains('Not enough seats')) {
        return AppResponse.failure('Plus de places disponibles.');
      }
      return AppResponse.failure('Erreur base de données: ${e.message}');
    } catch (e) {
      FieldTestLogger.logError('CREATE_BOOKING_UNKNOWN', e);
      debugPrint('🚨 [FIELD_TEST] Unexpected Error: $e');
      return AppResponse.failure('Une erreur est survenue lors de la réservation: $e');
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

  static List<Map<String, dynamic>> _cachedDriverBookings = [];

  /// Écoute les nouvelles réservations pour les trajets d'un chauffeur (Temps réel)
  static Stream<List<Map<String, dynamic>>> getDriverBookingsStream(String driverId) {
    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .asyncMap((_) async {
          try {
            final response = await _supabase
                .from('bookings')
                .select('*, trips:trip_id(driver_id, departure_city:departure_city_id(name), arrival_city:arrival_city_id(name)), profiles:profiles!user_id(full_name)')
                .eq('trips.driver_id', driverId)
                .order('created_at', ascending: false);
            _cachedDriverBookings = List<Map<String, dynamic>>.from(response);
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('cache_driver_bookings', jsonEncode(_cachedDriverBookings));
            return _cachedDriverBookings;
          } catch (e) {
            // Fallback
            if (_cachedDriverBookings.isEmpty) {
              final prefs = await SharedPreferences.getInstance();
              final cachedStr = prefs.getString('cache_driver_bookings');
              if (cachedStr != null) {
                try {
                  final List<dynamic> decoded = jsonDecode(cachedStr);
                  _cachedDriverBookings = List<Map<String, dynamic>>.from(decoded);
                } catch (_) {}
              }
            }
            return _cachedDriverBookings;
          }
        });
  }

  static Map<String, List<Map<String, dynamic>>> _cachedTripPassengers = {};

  /// Récupère la liste des passagers pour un trajet donné en temps réel
  static Stream<List<Map<String, dynamic>>> getTripPassengersStream(String tripId) {
    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('trip_id', tripId)
        .asyncMap((_) async {
          final res = await getTripPassengers(tripId);
          if (res.isSuccess && res.data != null) {
            _cachedTripPassengers[tripId] = res.data!;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('cache_trip_passengers_$tripId', jsonEncode(res.data!));
            return res.data!;
          }

          if (!_cachedTripPassengers.containsKey(tripId) || _cachedTripPassengers[tripId]!.isEmpty) {
            final prefs = await SharedPreferences.getInstance();
            final cachedStr = prefs.getString('cache_trip_passengers_$tripId');
            if (cachedStr != null) {
              try {
                final List<dynamic> decoded = jsonDecode(cachedStr);
                _cachedTripPassengers[tripId] = List<Map<String, dynamic>>.from(decoded);
              } catch (_) {}
            }
          }
          return _cachedTripPassengers[tripId] ?? [];
        });
  }

  /// Récupère la liste des passagers pour un trajet donné (Future)
  static Future<AppResponse<List<Map<String, dynamic>>>> getTripPassengers(String tripId) async {
    try {
      final data = await _supabase
          .from('bookings')
          .select('*, profiles:profiles!user_id(full_name, phone), tickets(*)')
          .eq('trip_id', tripId)
          .neq('status', 'cancelled');
      return AppResponse.success(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      debugPrint('Error getting trip passengers: $e');
      return AppResponse.failure('Impossible de charger les passagers: $e');
    }
  }

  /// Confirme ou valide la présence d'un passager
  static Future<AppResponse<void>> confirmPassengerPresence(String bookingId) async {
    try {
      await _supabase.from('bookings').update({
        'status': 'confirmed',
        'updated_at': DateTime.now().toIso8601String()
      }).eq('id', bookingId);
      return AppResponse.success(null, message: 'Passager confirmé !');
    } catch (e) {
      debugPrint('Error confirming passenger: $e');
      return AppResponse.failure('Échec de la confirmation.');
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

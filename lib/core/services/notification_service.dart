// ============================================================================
// Service Notification — gestion du temps réel avec Supabase
// ============================================================================

import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final _supabase = Supabase.instance.client;
  
  // Singleton
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Stream pour les nouvelles notifications (UI Listener)
  final _notificationController = StreamController<NotificationModel>.broadcast();
  Stream<NotificationModel> get onNotification => _notificationController.stream;

  RealtimeChannel? _channel;

  /// Initialise l'écoute en temps réel pour l'utilisateur actuel
  void initialize() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Arrêter l'ancien canal si existant
    _channel?.unsubscribe();

    // Création du canal Realtime
    _channel = _supabase
        .channel('public:notifications:user=$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final notification = NotificationModel.fromJson(payload.newRecord);
            _notificationController.add(notification);
          },
        )
        .subscribe();
  }

  /// Récupère l'historique des notifications
  Future<List<NotificationModel>> getNotifications() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => NotificationModel.fromJson(json)).toList();
  }

  /// Marque une notification comme lue
  Future<void> markAsRead(String notificationId) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  /// Notifie tous les passagers de la publication d'un nouveau trajet
  Future<void> notifyPassengersOfNewTrip({
    required String tripId,
    required String departureCity,
    required String arrivalCity,
    required String departureTime,
  }) async {
    try {
      // 1. Récupérer tous les passagers
      final passengersRes = await _supabase
          .from('profiles')
          .select('id')
          .eq('role', 'PASSENGER');

      final List<dynamic> passengers = passengersRes as List;
      if (passengers.isEmpty) return;

      // 2. Préparer les notifications par lot
      final List<Map<String, dynamic>> notifications = passengers.map((p) => {
        'user_id': p['id'],
        'title': 'Nouveau Trajet ! 🚌',
        'message': 'Un nouveau départ de $departureCity vers $arrivalCity est prévu à $departureTime.',
        'type': 'new_trip',
        'metadata': {'trip_id': tripId},
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      }).toList();

      // 3. Insertion par lot (batch insert)
      await _supabase.from('notifications').insert(notifications);
    } catch (e) {
      print('Erreur lors de la notification des passagers: $e');
    }
  }

  /// Nettoyage
  void dispose() {
    _channel?.unsubscribe();
    _notificationController.close();
  }
}

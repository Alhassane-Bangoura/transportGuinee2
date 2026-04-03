import 'dart:async';
import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class NotificationOverlay extends StatefulWidget {
  final Widget child;

  const NotificationOverlay({super.key, required this.child});

  @override
  State<NotificationOverlay> createState() => _NotificationOverlayState();
}

class _NotificationOverlayState extends State<NotificationOverlay> {
  late final StreamSubscription<NotificationModel> _subscription;
  NotificationModel? _activeNotification;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    // Initialisation du service et écoute
    final service = NotificationService();
    service.initialize();
    _subscription = service.onNotification.listen(_showNotification);
  }

  @override
  void dispose() {
    _subscription.cancel();
    _dismissTimer?.cancel();
    super.dispose();
  }

  void _showNotification(NotificationModel notification) {
    setState(() {
      _activeNotification = notification;
    });

    // Auto-dismiss après 5 secondes
    _dismissTimer?.cancel();
    _dismissTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _activeNotification = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_activeNotification != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: _buildNotificationCard(_activeNotification!),
          ),
      ],
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.premiumTeal.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.premiumTeal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(notification.type),
                color: AppColors.premiumTeal,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: AppTextStyles.headingLarge.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
              onPressed: () {
                setState(() {
                  _activeNotification = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'trip_publication':
        return Icons.directions_bus;
      case 'reservation_received':
        return Icons.confirmation_number;
      case 'payment_confirmed':
        return Icons.account_balance_wallet;
      case 'booking_confirmed':
        return Icons.check_circle;
      case 'trip_status_update':
        return Icons.notifications_active;
      default:
        return Icons.notifications;
    }
  }
}

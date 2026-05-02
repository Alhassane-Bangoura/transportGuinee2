import 'package:flutter/foundation.dart';

/// Utilitaire de log minimal pour le test terrain (Guinée)
class FieldTestLogger {
  static void logError(String context, dynamic error, [StackTrace? stackTrace]) {
    debugPrint('🚨 [FIELD_TEST_ERROR] Context: $context');
    debugPrint('Error: $error');
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
    // TODO: Possibilité d'envoyer ces logs à un service externe comme Sentry ou LogSnag
  }

  static void logBooking(String userId, String tripId, String status) {
    debugPrint('📅 [FIELD_TEST_BOOKING] User: $userId | Trip: $tripId | Status: $status');
  }

  static void logNetwork(String url, String method, int? statusCode) {
    debugPrint('🌐 [FIELD_TEST_NETWORK] $method $url | Status: $statusCode');
  }
}

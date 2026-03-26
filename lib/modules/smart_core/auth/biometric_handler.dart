import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class BiometricHandler {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const _storage = FlutterSecureStorage();
  static const String _biometricEnabledKey = 'biometric_enabled';

  /// Vérifie si le support biométrique est disponible sur l'appareil
  static Future<bool> isBiometricAvailable() async {
    final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
    return canAuthenticate;
  }

  /// Vérifie si l'utilisateur a activé la connexion biométrique dans ses paramètres
  static Future<bool> isBiometricEnabled() async {
    String? enabled = await _storage.read(key: _biometricEnabledKey);
    return enabled == 'true';
  }

  /// Active ou désactive la connexion biométrique
  static Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
  }

  /// Tente une authentification biométrique
  static Future<bool> authenticate() async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Veuillez vous authentifier pour accéder à votre compte GuineeTransport',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return didAuthenticate;
    } catch (e) {
      debugPrint('Erreur d\'authentification biométrique: $e');
      return false;
    }
  }

  /// Récupère la liste des biométries disponibles
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _auth.getAvailableBiometrics();
  }
}

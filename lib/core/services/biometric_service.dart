import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const _storage = FlutterSecureStorage();
  
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _userEmailKey = 'biometric_user_email';
  static const String _userPasswordKey = 'biometric_user_password';

  /// Check if the device is capable of biometric authentication
  static Future<bool> isAvailable() async {
    if (!kIsWeb && Platform.isLinux) {
      debugPrint('[BiometricService] Biometrics disabled on Linux to avoid MissingPluginException');
      return false;
    }

    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } catch (e) {
      debugPrint('[BiometricService] Error checking availability: $e');
      return false;
    }
  }

  /// Get list of available biometrics (fingerprint, face, etc.)
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      if (!kIsWeb && Platform.isLinux) return [];
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('[BiometricService] Error getting biometrics: $e');
      return [];
    }
  }

  /// Perform biometric authentication
  static Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Veuillez vous authentifier pour accéder à Guinée Transport',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  /// Set biometric preference
  static Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
  }

  /// Get biometric preference
  static Future<bool> isBiometricEnabled() async {
    final String? value = await _storage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  /// Save credentials for biometric login
  static Future<void> saveCredentials(String email, String password) async {
    await _storage.write(key: _userEmailKey, value: email);
    await _storage.write(key: _userPasswordKey, value: password);
  }

  /// Get saved email
  static Future<String?> getSavedEmail() async {
    return await _storage.read(key: _userEmailKey);
  }

  /// Get saved password
  static Future<String?> getSavedPassword() async {
    return await _storage.read(key: _userPasswordKey);
  }

  /// Get stored credentials as a map
  static Future<Map<String, String>?> getStoredCredentials() async {
    final email = await getSavedEmail();
    final password = await getSavedPassword();
    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }

  /// Clear biometric data
  static Future<void> clearBiometricData() async {
    await _storage.delete(key: _biometricEnabledKey);
    await _storage.delete(key: _userEmailKey);
    await _storage.delete(key: _userPasswordKey);
  }
}

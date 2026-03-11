import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import 'mock_data.dart';

// ============================================================================
// AuthService — Gestion de l'authentification (MODE DÉMO UNIQUEMENT)
// ============================================================================

class AuthService {
  /// Retourne l'utilisateur connecté (Désactivé en mode Mock)
  static dynamic get currentUser => null;

  /// Vérifie si l'utilisateur est connecté
  static bool get isLoggedIn => true;

  // ─── Profil ──────────────────────────────────────────────────────────────

  /// Récupère le profil complet de l'utilisateur connecté
  static Future<UserProfile?> getCurrentProfile() async {
    return MockData.passengerProfile;
  }

  // ─── Validation ──────────────────────────────────────────────────────────

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'L\'email est obligatoire';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Format d\'email invalide';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Le téléphone est obligatoire';
    String clean = value.replaceAll(' ', '').replaceAll('-', '');
    if (clean.startsWith('+224')) clean = clean.substring(4);
    if (clean.length != 9 || !clean.startsWith('6')) {
      return 'Numéro invalide (ex: 620 00 00 00)';
    }
    return null;
  }

  // ─── Inscription ─────────────────────────────────────────────────────────

  /// Inscrit un nouvel utilisateur (MOCK)
  static Future<UserProfile?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String roleKey,
    Map<String, dynamic>? metadata,
  }) async {
    debugPrint('[AuthService] signUp MOCK email=$email role=$roleKey');
    await Future.delayed(const Duration(milliseconds: 800));
    
    switch (roleKey.toLowerCase()) {
      case 'driver':
        return MockData.driverProfile;
      case 'syndicate':
        return MockData.syndicateProfile;
      case 'station_admin':
        return MockData.stationAdminProfile;
      default:
        return MockData.passengerProfile;
    }
  }

  // ─── Connexion ───────────────────────────────────────────────────────────

  /// Connecte l'utilisateur (MODE MOCK)
  static Future<UserProfile?> signIn({
    required String email,
    required String password,
  }) async {
    debugPrint('[AuthService] signIn MOCK email=$email');
    // On simule un court délai pour montrer le chargement sans bloquer l'UI
    await Future.delayed(const Duration(milliseconds: 500));
    
    final lowEmail = email.toLowerCase();
    if (lowEmail.contains('driver') || lowEmail.contains('chauffeur')) {
      return MockData.driverProfile;
    } else if (lowEmail.contains('syndicate') || lowEmail.contains('syndicat')) {
      return MockData.syndicateProfile;
    } else if (lowEmail.contains('gare') || lowEmail.contains('admin')) {
      return MockData.stationAdminProfile;
    }
    
    return MockData.passengerProfile;
  }

  // ─── Déconnexion ─────────────────────────────────────────────────────────

  static Future<void> signOut() async {
    debugPrint('[AuthService] signOut MOCK');
  }

  // ─── Mise à jour du profil ───────────────────────────────────────────────

  static Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    debugPrint('[AuthService] updateProfile MOCK');
  }
}

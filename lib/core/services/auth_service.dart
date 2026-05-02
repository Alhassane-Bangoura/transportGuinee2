import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../utils/app_response.dart';
import 'booking_service.dart';
import 'trip_service.dart';
import 'wallet_service.dart';

// ============================================================================
// AuthService — Gestion de l'authentification via Supabase
// ============================================================================

class AuthService {
  static final _supabase = Supabase.instance.client;

  /// Retourne l'utilisateur connecté
  static User? get currentUser => _supabase.auth.currentUser;

  /// Vérifie si l'utilisateur est connecté
  static bool get isLoggedIn => currentUser != null;

  // ─── Profil ──────────────────────────────────────────────────────────────

  /// Récupère le profil complet de l'utilisateur connecté
  static Future<AppResponse<UserProfile>> getCurrentProfile() async {
    final user = currentUser;
    if (user == null) {
      debugPrint('[AuthService] No current user found.');
      return const AppResponse.failure('Utilisateur non connecté');
    }

    debugPrint('[AuthService] Fetching profile for user ID: ${user.id}');

    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedProfile = prefs.getString('cached_profile_${user.id}');
      
      // On tente de récupérer depuis la DB
      debugPrint('[AuthService] FETCHING PROFILE FROM DB for user ${user.id}...');
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      
      if (data == null) {
        // Si pas en DB, on regarde si on a un cache (fallback)
        if (cachedProfile != null) {
          debugPrint('[AuthService] No profile in DB, using cached profile');
          return AppResponse.success(UserProfile.fromJson(jsonDecode(cachedProfile)));
        }
        return const AppResponse.failure('Profil utilisateur introuvable.');
      }

      // Mise à jour du cache local
      await prefs.setString('cached_profile_${user.id}', jsonEncode(data));
      
      debugPrint('[AuthService] Profile fetched successfully from DB');
      return AppResponse.success(UserProfile.fromJson(data));
    } catch (e) {
      // Fallback cache en cas d'erreur réseau
      final prefs = await SharedPreferences.getInstance();
      final cachedProfile = prefs.getString('cached_profile_${user.id}');
      if (cachedProfile != null) {
        debugPrint('[AuthService] Network error, using cached profile');
        return AppResponse.success(UserProfile.fromJson(jsonDecode(cachedProfile)));
      }
      return AppResponse.failure('Erreur de récupération du profil : $e');
    }
  }

  // ... (validateEmail and validatePhone methods unchanged)
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

  /// Inscrit un nouvel utilisateur via Supabase
  static Future<AppResponse<AuthResponse>> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String roleKey,
    String? stationId,
    String? routeId,
    List<String>? routeIds,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Préfixe pour le rôle (visible dans le dashboard Supabase Auth)
      final String rolePrefix = {
        'driver': '[CHAUFFEUR] ',
        'passenger': '[PASSAGER] ',
        'syndicate': '[SYNDICAT] ',
        'station_admin': '[ADMIN] ',
      }[roleKey] ?? '';

      final Map<String, dynamic> userMetadata = {
        'full_name': roleKey == 'passenger' ? fullName : '$rolePrefix$fullName',
        'phone': phone,
        'role_key': roleKey,
        if (stationId != null) 'station_id': stationId,
        if (routeId != null) 'route_id': routeId,
        ...?(metadata),
      };

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: userMetadata,
      );

      // Si c'est un syndicat avec plusieurs trajets, on les insère dans syndicate_routes
      if (response.user != null && roleKey == 'syndicate' && routeIds != null && routeIds.isNotEmpty) {
        final List<Map<String, dynamic>> routeEntries = routeIds.map((id) => {
          'syndicate_id': response.user!.id,
          'route_id': id,
        }).toList();
        
        await _supabase.from('syndicate_routes').insert(routeEntries);
      }

      return AppResponse.success(response);
    } catch (e) {
      debugPrint('[AuthService] SignUp Error: $e');
      return AppResponse.failure(e.toString());
    }
  }

  // ─── Connexion ───────────────────────────────────────────────────────────

  /// Connecte l'utilisateur via Supabase
  static Future<AppResponse<UserProfile>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) return const AppResponse.failure('Échec de la connexion');
      return await getCurrentProfile();
    } catch (e) {
      debugPrint('[AuthService] SignIn Error: $e');
      String msg = e.toString();
      if (msg.contains('Invalid login credentials')) {
        msg = 'Email ou mot de passe incorrect.';
      }
      return AppResponse.failure(msg);
    }
  }

  // ─── Déconnexion ─────────────────────────────────────────────────────────

  static Future<void> signOut() async {
    debugPrint('[AuthService] SIGN OUT - Clearing all caches...');
    // Nettoyage complet des caches lors de la déconnexion
    BookingService.clearCache();
    TripService.clearCache();
    WalletService().reset();
    
    await _supabase.auth.signOut();
    debugPrint('[AuthService] Sign out complete');
  }

  // ─── Mise à jour du profil ───────────────────────────────────────────────

  static Future<AppResponse<void>> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
  }) async {
    final user = currentUser;
    if (user == null) return const AppResponse.failure('Non connecté');

    try {
      final updates = <String, dynamic>{
        if (fullName != null) 'full_name': fullName,
        if (phone != null) 'phone': phone,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (metadata != null) 'metadata': metadata,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('profiles').update(updates).eq('id', user.id);

      // Invalider le cache local pour forcer un re-fetch frais au prochain getCurrentProfile
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_profile_${user.id}');

      return const AppResponse.success(null);
    } catch (e) {
      return AppResponse.failure(e.toString());
    }
  }

  /// Change le mot de passe de l'utilisateur après vérification de l'ancien
  static Future<AppResponse<void>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final user = currentUser;
    if (user == null || user.email == null) return const AppResponse.failure('Utilisateur non connecté');

    try {
      // 1. Vérifier l'ancien mot de passe en tentant une connexion
      await _supabase.auth.signInWithPassword(
        email: user.email!,
        password: oldPassword,
      );

      // 2. Si la connexion réussit, mettre à jour le mot de passe
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      
      return const AppResponse.success(null);
    } catch (e) {
      debugPrint('[AuthService] ChangePassword Error: $e');
      String msg = e.toString();
      if (msg.contains('Invalid login credentials')) {
        msg = 'L\'ancien mot de passe est incorrect.';
      } else if (msg.contains('Password should be')) {
        msg = 'Le nouveau mot de passe est trop court.';
      }
      return AppResponse.failure(msg);
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

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
  static Future<UserProfile?> getCurrentProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
      return UserProfile.fromJson(data);
    } catch (e) {
      debugPrint('[AuthService] Error fetching profile: $e');
      return null;
    }
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

  /// Inscrit un nouvel utilisateur via Supabase
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String roleKey,
    int? stationId,
    int? routeId,
    List<int>? routeIds,
    Map<String, dynamic>? metadata,
  }) async {
    final Map<String, dynamic> userMetadata = {
      'full_name': fullName,
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

    return response;
  }

  // ─── Connexion ───────────────────────────────────────────────────────────

  /// Connecte l'utilisateur via Supabase
  static Future<UserProfile?> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) return null;
    return await getCurrentProfile();
  }

  // ─── Déconnexion ─────────────────────────────────────────────────────────

  static Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // ─── Mise à jour du profil ───────────────────────────────────────────────

  static Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
  }) async {
    final user = currentUser;
    if (user == null) return;

    final updates = <String, dynamic>{
      if (fullName != null) 'full_name': fullName,
      if (phone != null) 'phone': phone,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (metadata != null) 'metadata': metadata,
      'updated_at': DateTime.now().toIso8601String(),
    };

    await _supabase.from('profiles').update(updates).eq('id', user.id);
  }
}

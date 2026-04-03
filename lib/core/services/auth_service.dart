import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../utils/app_response.dart';

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
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle(); // Utiliser maybeSingle pour éviter l'exception si vide
      
      if (data == null) {
        debugPrint('[AuthService] No profile found for user ${user.id}');
        return const AppResponse.failure('Profil utilisateur introuvable. Veuillez contacter le support.');
      }

      debugPrint('[AuthService] Profile fetched successfully');
      return AppResponse.success(UserProfile.fromJson(data));
    } on PostgrestException catch (e) {
      debugPrint('[AuthService] Supabase Error (${e.code}): ${e.message}');
      if (e.code == 'PGRST301') {
        return const AppResponse.failure('Erreur de permission (RLS).');
      }
      return AppResponse.failure('Erreur base de données : ${e.message}');
    } catch (e) {
      debugPrint('[AuthService] Unknown error fetching profile: $e');
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
    await _supabase.auth.signOut();
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
      return const AppResponse.success(null);
    } catch (e) {
      return AppResponse.failure(e.toString());
    }
  }
}

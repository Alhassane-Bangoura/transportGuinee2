import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_assets.dart';

// ============================================================================
// Modèle UserProfile — correspond à la table profiles dans Supabase
// ============================================================================

class UserProfile {
  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final String role; 
  final String? stationId;
  final String? routeId;
  final String? syndicateId;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const UserProfile({
    required this.id,
    required this.fullName,
    this.email,
    this.phone,
    this.avatarUrl,
    required this.role,
    this.stationId,
    this.routeId,
    this.syndicateId,
    required this.createdAt,
    this.metadata,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'passenger',
      stationId: json['station_id'] as String?,
      routeId: json['route_id'] as String?,
      syndicateId: json['syndicate_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converts Supabase role (UPPER_CASE) to descriptive role
  String get appRole => role;

  /// Gets the first name from fullName
  String get firstName => cleanFullName.isNotEmpty ? cleanFullName.split(' ').first : 'Admin';

  /// Removes role prefixes like [PASSAGER] or Passager
  String get cleanFullName {
    String name = fullName;
    // Supprimer les préfixes entre crochets [PASSAGER], [CHAUFFEUR], etc.
    name = name.replaceAll(RegExp(r'\[.*?\]\s*', caseSensitive: false), '');
    // Supprimer le mot "passager" s'il est au début ou n'importe où comme titre
    name = name.replaceAll(RegExp(r'\bpassager\b\s*', caseSensitive: false), '');
    // Supprimer les espaces doubles
    name = name.replaceAll(RegExp(r'\s+'), ' ');
    return name.trim().isEmpty ? 'Utilisateur' : name.trim();
  }

  // Helpers for common metadata fields
  String? get cityId => metadata?['city_id']?.toString();
  String? get employeeId => metadata?['employee_id'] as String?;
  String? get functionRole => metadata?['function'] as String?;

  /// Path to the local profile image picked during registration
  String? get localProfileImagePath => metadata?['local_profile_image_path'] as String?;

  /// Returns the appropriate ImageProvider for the user's profile picture
  ImageProvider get profileImage {
    if (avatarUrl != null && avatarUrl!.startsWith('http')) {
      return NetworkImage(avatarUrl!);
    }
    
    final localPath = localProfileImagePath;
    if (localPath != null) {
      final file = File(localPath);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    
    // Default avatar
    return NetworkImage(AppAssets.stationPreview);
  }
}

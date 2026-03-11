// ============================================================================
// Modèle UserProfile — correspond à la table profiles dans Supabase
// ============================================================================

class UserProfile {
  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final String role; // passenger, driver, syndicate, station_admin
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const UserProfile({
    required this.id,
    required this.fullName,
    this.email,
    this.phone,
    this.avatarUrl,
    required this.role,
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
      createdAt: DateTime.parse(json['created_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converts Supabase role (snake_case) to app role (UPPER_CASE)
  String get appRole {
    switch (role) {
      case 'passenger':
        return 'PASSAGER';
      case 'driver':
        return 'CHAUFFEUR';
      case 'syndicate':
        return 'SYNDICAT';
      case 'station_admin':
        return 'GARE';
      default:
        return 'PASSAGER';
    }
  }
}

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
  String get firstName => fullName.isNotEmpty ? fullName.split(' ').first : 'Admin';

  // Helpers for common metadata fields
  String? get cityId => metadata?['city_id']?.toString();
  String? get employeeId => metadata?['employee_id'] as String?;
  String? get functionRole => metadata?['function'] as String?;
}

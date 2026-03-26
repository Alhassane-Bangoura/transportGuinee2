// ============================================================================
// Modèle Trip — correspond à la vue trips_with_details dans Supabase
// ============================================================================

class Trip {
  final String id;
  final String routeId;
  final String? vehicleId;
  final String? driverId;
  final DateTime departureTime;
  final int availableSeats;
  final double price;
  final String status;

  // Champs de la vue trips_with_details
  final String departureCityName;
  final String arrivalCityName;
  final String departureStationName;
  final String arrivalStationName;
  final String? vehicleType;
  final List<dynamic> amenities;
  final int? totalSeats;
  final String? licensePlate;
  final double? distance;
  final int? estimatedDuration;
  final String? quayNumber;

  const Trip({
    required this.id,
    required this.routeId,
    this.vehicleId,
    this.driverId,
    required this.departureTime,
    required this.availableSeats,
    required this.price,
    required this.status,
    required this.departureCityName,
    required this.arrivalCityName,
    required this.departureStationName,
    required this.arrivalStationName,
    this.vehicleType,
    this.amenities = const [],
    this.totalSeats,
    this.licensePlate,
    this.distance,
    this.estimatedDuration,
    this.quayNumber,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      routeId: json['route_id'] as String,
      vehicleId: json['vehicle_id'] as String?,
      driverId: json['driver_id'] as String?,
      departureTime: DateTime.parse(json['departure_time'] as String),
      availableSeats: (json['available_seats'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      status: json['status'] as String? ?? 'scheduled',
      departureCityName: json['departure_city_name'] as String? ?? '',
      arrivalCityName: json['arrival_city_name'] as String? ?? '',
      departureStationName: json['departure_station_name'] as String? ?? '',
      arrivalStationName: json['arrival_station_name'] as String? ?? '',
      vehicleType: json['vehicle_type'] as String?,
      amenities: (json['amenities'] as List<dynamic>?) ?? [],
      totalSeats: (json['total_seats'] as num?)?.toInt(),
      licensePlate: json['license_plate'] as String?,
      distance: (json['distance'] as num?)?.toDouble(),
      estimatedDuration: (json['estimated_duration'] as num?)?.toInt(),
      quayNumber: json['quay_number'] as String?,
    );
  }

  String get formattedPrice => '${price.toStringAsFixed(0)} GNF';

  String get formattedDuration {
    if (estimatedDuration == null) return '';
    final h = estimatedDuration! ~/ 60;
    final m = estimatedDuration! % 60;
    if (h == 0) return '${m}min';
    if (m == 0) return '${h}h';
    return '${h}h${m.toString().padLeft(2, '0')}';
  }
}

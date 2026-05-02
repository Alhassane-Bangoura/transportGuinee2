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
  final String? syndicateName;
  final String? vehicleImage;
  final DateTime createdAt;

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
    this.syndicateName,
    this.vehicleImage,
    required this.createdAt,
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
      syndicateName: json['syndicate_name'] as String?,
      vehicleImage: json['vehicle_image'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'route_id': routeId,
      'vehicle_id': vehicleId,
      'driver_id': driverId,
      'departure_time': departureTime.toIso8601String(),
      'available_seats': availableSeats,
      'price': price,
      'status': status,
      'departure_city_name': departureCityName,
      'arrival_city_name': arrivalCityName,
      'departure_station_name': departureStationName,
      'arrival_station_name': arrivalStationName,
      'vehicle_type': vehicleType,
      'amenities': amenities,
      'total_seats': totalSeats,
      'license_plate': licensePlate,
      'distance': distance,
      'estimated_duration': estimatedDuration,
      'quay_number': quayNumber,
      'syndicate_name': syndicateName,
      'vehicle_image': vehicleImage,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

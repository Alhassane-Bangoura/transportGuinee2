// ============================================================================
// Modèle Booking + Ticket — correspond aux tables bookings & tickets Supabase
// ============================================================================

class Ticket {
  final String id;
  final String bookingId;
  final String qrCode;
  final String status; // valid, used, cancelled

  const Ticket({
    required this.id,
    required this.bookingId,
    required this.qrCode,
    required this.status,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      qrCode: json['qr_code'] as String,
      status: json['status'] as String? ?? 'valid',
    );
  }

  bool get isActive => status == 'valid';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'qr_code': qrCode,
      'status': status,
    };
  }
}

class Booking {
  final String id;
  final String tripId;
  final String userId;
  final int seats;
  final double? totalPrice;
  final String status; // pending, confirmed, completed, cancelled
  final DateTime createdAt;

  // Champs enrichis via join
  final String? departureCityName;
  final String? arrivalCityName;
  final String? departureStationName;
  final String? arrivalStationName;
  final DateTime? departureTime;
  final String? passengerName;
  final String? passengerPhone;
  final String? passengerAvatarUrl;
  final String? driverName;
  final String? driverPhone;
  final String? driverAvatarUrl;
  final String? vehicleModel;
  final String? vehiclePlate;
  final String? vehiclePhotoUrl;

  final String? paymentMethod;
 
  // Billet associé (join)
  final Ticket? ticket;

  const Booking({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.seats,
    this.totalPrice,
    required this.status,
    required this.createdAt,
    this.departureCityName,
    this.arrivalCityName,
    this.departureStationName,
    this.arrivalStationName,
    this.departureTime,
    this.passengerName,
    this.passengerPhone,
    this.passengerAvatarUrl,
    this.driverName,
    this.driverPhone,
    this.driverAvatarUrl,
    this.vehicleModel,
    this.vehiclePlate,
    this.vehiclePhotoUrl,
    this.paymentMethod,
    this.ticket,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Le join Supabase retourne les trips et tickets imbriqués
    final tripData = json['trips'] as Map<String, dynamic>?;
    final routeData = tripData?['routes'] as Map<String, dynamic>?;
    final vehicleData = tripData?['vehicles'] as Map<String, dynamic>?;
    final ticketList = json['tickets'] as List<dynamic>?;
    final profileData = json['profiles'] as Map<String, dynamic>?;

    return Booking(
      id: json['id'] as String,
      tripId: json['trip_id'] as String,
      userId: json['user_id'] as String,
      seats: (json['seats'] as num).toInt(),
      totalPrice: (json['total_price'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
      departureCityName: routeData?['departure_city']?['name'] as String?,
      arrivalCityName: routeData?['arrival_city']?['name'] as String?,
      departureStationName: routeData?['departure_station']?['name'] as String?,
      arrivalStationName: routeData?['arrival_station']?['name'] as String?,
      departureTime: tripData?['departure_time'] != null
          ? DateTime.parse(tripData!['departure_time'] as String)
          : null,
      passengerName: profileData?['full_name'] as String?,
      passengerPhone: profileData?['phone'] as String?,
      passengerAvatarUrl: profileData?['avatar_url'] as String?,
      driverName: tripData?['driver']?['full_name'] as String?,
      driverPhone: tripData?['driver']?['phone'] as String?,
      driverAvatarUrl: tripData?['driver']?['avatar_url'] as String?,
      vehicleModel: vehicleData?['type'] as String?,
      vehiclePlate: vehicleData?['license_plate'] as String?,
      vehiclePhotoUrl: vehicleData?['photo_url'] as String?, // Si dispo
      paymentMethod: json['payment_method'] as String?,
      ticket: ticketList != null && ticketList.isNotEmpty
          ? Ticket.fromJson(ticketList.first as Map<String, dynamic>)
          : null,
    );
  }

  bool get isActive => ['pending', 'confirmed'].contains(status);
  String get formattedPrice =>
      totalPrice != null ? '${totalPrice!.toStringAsFixed(0)} GNF' : '-';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_id': tripId,
      'user_id': userId,
      'seats': seats,
      'total_price': totalPrice,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'passenger_name': passengerName,
      'passenger_phone': passengerPhone,
      'passenger_avatar': passengerAvatarUrl,
      'driver_name': driverName,
      'vehicle_model': vehicleModel,
      'vehicle_plate': vehiclePlate,
      if (departureCityName != null || arrivalCityName != null || departureStationName != null || arrivalStationName != null)
        'trips': {
          if (departureTime != null) 'departure_time': departureTime!.toIso8601String(),
          'routes': {
            if (departureCityName != null) 'departure_city': {'name': departureCityName},
            if (arrivalCityName != null) 'arrival_city': {'name': arrivalCityName},
            if (departureStationName != null) 'departure_station': {'name': departureStationName},
            if (arrivalStationName != null) 'arrival_station': {'name': arrivalStationName},
          },
          'vehicles': {
            'type': vehicleModel,
            'license_plate': vehiclePlate,
          }
        },
      if (ticket != null) 'tickets': [ticket!.toJson()],
    };
  }
}


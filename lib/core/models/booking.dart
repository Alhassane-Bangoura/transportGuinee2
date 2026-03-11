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
    this.ticket,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Le join Supabase retourne les trips et tickets imbriqués
    final tripData = json['trips'] as Map<String, dynamic>?;
    final routeData = tripData?['routes'] as Map<String, dynamic>?;
    final ticketList = json['tickets'] as List<dynamic>?;

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
      ticket: ticketList != null && ticketList.isNotEmpty
          ? Ticket.fromJson(ticketList.first as Map<String, dynamic>)
          : null,
    );
  }

  bool get isActive => ['pending', 'confirmed'].contains(status);
  String get formattedPrice =>
      totalPrice != null ? '${totalPrice!.toStringAsFixed(0)} GNF' : '-';
}

class RouteModel {
  final int id;
  final int departureStationId;
  final int arrivalStationId;
  final String? departureStationName; // From joins
  final String? arrivalStationName; // From joins

  final String? syndicateId; // The syndicate managing this route (UUID)

  RouteModel({
    required this.id,
    required this.departureStationId,
    required this.arrivalStationId,
    this.departureStationName,
    this.arrivalStationName,
    this.syndicateId,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] as int,
      departureStationId: json['departure_station_id'] as int,
      arrivalStationId: json['arrival_station_id'] as int,
      departureStationName: json['departure_station_name'] as String?,
      arrivalStationName: json['arrival_station_name'] as String?,
      syndicateId: json['syndicate_id'] as String?,
    );
  }

  String get displayName => '${departureStationName ?? 'Départ'} ➔ ${arrivalStationName ?? 'Arrivée'}';
}

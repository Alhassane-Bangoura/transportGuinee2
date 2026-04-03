class RouteModel {
  final String id;
  final String departureStationId;
  final String arrivalStationId;
  final String? departureStationName; // From joins
  final String? arrivalStationName; // From joins
  final String? arrivalCityName; // From joins
  final String? syndicateId; // The syndicate managing this route (UUID)

  RouteModel({
    required this.id,
    required this.departureStationId,
    required this.arrivalStationId,
    this.departureStationName,
    this.arrivalStationName,
    this.arrivalCityName,
    this.syndicateId,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] as String,
      departureStationId: json['departure_station_id'] as String,
      arrivalStationId: json['arrival_station_id'] as String,
      departureStationName: json['departure_station_name'] as String?,
      arrivalStationName: json['arrival_station_name'] as String?,
      arrivalCityName: json['arrival_city_name'] as String?,
      syndicateId: json['syndicate_id'] as String?,
    );
  }

  String get displayName => '${departureStationName ?? 'Départ'} - ${arrivalCityName ?? arrivalStationName ?? 'Arrivée'}';
}

class Station {
  final String id;
  final String name;
  final String cityId;
  final String? address;

  Station({
    required this.id,
    required this.name,
    required this.cityId,
    this.address,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'] as String,
      name: json['name'] as String,
      cityId: json['city_id'] as String,
      address: json['address'] as String?,
    );
  }
}

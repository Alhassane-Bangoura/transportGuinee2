class Station {
  final int id;
  final String name;
  final int cityId;
  final String? address;

  Station({
    required this.id,
    required this.name,
    required this.cityId,
    this.address,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'] as int,
      name: json['name'] as String,
      cityId: json['city_id'] as int,
      address: json['address'] as String?,
    );
  }
}

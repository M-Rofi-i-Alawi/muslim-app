class KiblatModel {
  final double direction;
  final double latitude;
  final double longitude;

  KiblatModel({
    required this.direction,
    required this.latitude,
    required this.longitude,
  });

  factory KiblatModel.fromJson(Map<String, dynamic> json, double lat, double lon) {
    return KiblatModel(
      direction: (json['direction'] ?? 0).toDouble(),
      latitude: lat,
      longitude: lon,
    );
  }
}
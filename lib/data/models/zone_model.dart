import 'package:hive/hive.dart';

part 'zone_model.g.dart';

@HiveType(typeId: 3)
class ZoneModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double latitude;

  @HiveField(3)
  double longitude;

  @HiveField(4)
  double radius;

  @HiveField(5)
  String type; // 'home', 'supermarket', 'restaurant'

  @HiveField(6)
  bool isActive;

  ZoneModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.radius = 150.0,
    required this.type,
    this.isActive = true,
  });

  // Convert to Zone object for geofence_foreground_service
  Map<String, dynamic> toGeofenceZone() {
    return {
      'id': id,
      'lat': latitude,
      'lng': longitude,
      'radius': radius,
      'data': {
        'name': name,
        'type': type,
      },
    };
  }

  // Create from JSON (for Overpass API response)
  factory ZoneModel.fromJson(Map<String, dynamic> json, String type) {
    return ZoneModel(
      id: json['id'].toString(),
      name: json['tags']?['name'] ?? 'Unknown Place',
      latitude: json['lat'],
      longitude: json['lon'],
      radius: 150.0,
      type: type,
      isActive: true,
    );
  }

  @override
  String toString() {
    return 'ZoneModel(id: $id, name: $name, type: $type, lat: $latitude, lng: $longitude, radius: $radius)';
  }
}

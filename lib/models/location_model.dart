import 'package:hive/hive.dart';

part 'location_model.g.dart';

@HiveType(typeId: 2)
class CompanyLocation {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String address;
  
  @HiveField(3)
  final double latitude;
  
  @HiveField(4)
  final double longitude;
  
  @HiveField(5)
  final double radius;
  
  @HiveField(6)
  final String companyId;
  
  @HiveField(7)
  final bool isActive;
  
  @HiveField(8)
  final DateTime createdAt;
  
  @HiveField(9)
  final DateTime updatedAt;

  CompanyLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.radius = 1000.0, // Default 1km
    required this.companyId,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  CompanyLocation copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    double? radius,
    String? companyId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CompanyLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      companyId: companyId ?? this.companyId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calculate distance from another location in meters
  double distanceFrom(double lat, double lng) {
    const double earthRadius = 6371000; // meters
    final double dLat = (lat - latitude) * (3.141592653589793 / 180);
    final double dLng = (lng - longitude) * (3.141592653589793 / 180);
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(latitude * (3.141592653589793 / 180)) * 
        cos(lat * (3.141592653589793 / 180)) *
        sin(dLng / 2) * sin(dLng / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  // Check if a location is within the radius
  bool isWithinRadius(double lat, double lng) {
    return distanceFrom(lat, lng) <= radius;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'companyId': companyId,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CompanyLocation.fromJson(Map<String, dynamic> json) {
    return CompanyLocation(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      radius: json['radius']?.toDouble() ?? 1000.0,
      companyId: json['companyId'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  @override
  String toString() {
    return 'CompanyLocation(id: $id, name: $name, latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CompanyLocation && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}

@HiveType(typeId: 3)
class LocationLog {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String employeeId;
  
  @HiveField(2)
  final DateTime timestamp;
  
  @HiveField(3)
  final double latitude;
  
  @HiveField(4)
  final double longitude;
  
  @HiveField(5)
  final double accuracy;
  
  @HiveField(6)
  final String action; // 'clock_in', 'clock_out', 'location_check'
  
  @HiveField(7)
  final bool isWithinRadius;

  LocationLog({
    required this.id,
    required this.employeeId,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.action,
    required this.isWithinRadius,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'action': action,
      'isWithinRadius': isWithinRadius,
    };
  }

  factory LocationLog.fromJson(Map<String, dynamic> json) {
    return LocationLog(
      id: json['id'] ?? '',
      employeeId: json['employeeId'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      accuracy: json['accuracy']?.toDouble() ?? 0.0,
      action: json['action'] ?? '',
      isWithinRadius: json['isWithinRadius'] ?? false,
    );
  }
}

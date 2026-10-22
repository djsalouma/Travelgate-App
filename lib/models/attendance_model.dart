import 'package:hive/hive.dart';

part 'attendance_model.g.dart';

@HiveType(typeId: 1)
class AttendanceRecord {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String employeeId;
  
  @HiveField(2)
  final DateTime date;
  
  @HiveField(3)
  final DateTime? clockInTime;
  
  @HiveField(4)
  final DateTime? clockOutTime;
  
  @HiveField(5)
  final String status;
  
  @HiveField(6)
  final double? clockInLatitude;
  
  @HiveField(7)
  final double? clockInLongitude;
  
  @HiveField(8)
  final double? clockOutLatitude;
  
  @HiveField(9)
  final double? clockOutLongitude;
  
  @HiveField(10)
  final bool isWithinRadius;
  
  @HiveField(11)
  final int lateMinutes;
  
  @HiveField(12)
  final int earlyDepartureMinutes;
  
  @HiveField(13)
  final String? notes;
  
  @HiveField(14)
  final DateTime createdAt;
  
  @HiveField(15)
  final DateTime updatedAt;

  AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.date,
    this.clockInTime,
    this.clockOutTime,
    required this.status,
    this.clockInLatitude,
    this.clockInLongitude,
    this.clockOutLatitude,
    this.clockOutLongitude,
    this.isWithinRadius = false,
    this.lateMinutes = 0,
    this.earlyDepartureMinutes = 0,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Calculate working hours
  Duration get workingHours {
    if (clockInTime == null || clockOutTime == null) {
      return Duration.zero;
    }
    return clockOutTime!.difference(clockInTime!);
  }

  // Check if fully present (clocked in and out within radius)
  bool get isFullyPresent {
    return clockInTime != null && 
           clockOutTime != null && 
           isWithinRadius &&
           lateMinutes <= 0 &&
           earlyDepartureMinutes <= 0;
  }

  // Check if late
  bool get isLate => lateMinutes > 0;
  
  // Check if early departure
  bool get isEarlyDeparture => earlyDepartureMinutes > 0;
  
  // Check if absent
  bool get isAbsent => clockInTime == null && clockOutTime == null;

  AttendanceRecord copyWith({
    String? id,
    String? employeeId,
    DateTime? date,
    DateTime? clockInTime,
    DateTime? clockOutTime,
    String? status,
    double? clockInLatitude,
    double? clockInLongitude,
    double? clockOutLatitude,
    double? clockOutLongitude,
    bool? isWithinRadius,
    int? lateMinutes,
    int? earlyDepartureMinutes,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      clockInTime: clockInTime ?? this.clockInTime,
      clockOutTime: clockOutTime ?? this.clockOutTime,
      status: status ?? this.status,
      clockInLatitude: clockInLatitude ?? this.clockInLatitude,
      clockInLongitude: clockInLongitude ?? this.clockInLongitude,
      clockOutLatitude: clockOutLatitude ?? this.clockOutLatitude,
      clockOutLongitude: clockOutLongitude ?? this.clockOutLongitude,
      isWithinRadius: isWithinRadius ?? this.isWithinRadius,
      lateMinutes: lateMinutes ?? this.lateMinutes,
      earlyDepartureMinutes: earlyDepartureMinutes ?? this.earlyDepartureMinutes,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'date': date.toIso8601String(),
      'clockInTime': clockInTime?.toIso8601String(),
      'clockOutTime': clockOutTime?.toIso8601String(),
      'status': status,
      'clockInLatitude': clockInLatitude,
      'clockInLongitude': clockInLongitude,
      'clockOutLatitude': clockOutLatitude,
      'clockOutLongitude': clockOutLongitude,
      'isWithinRadius': isWithinRadius,
      'lateMinutes': lateMinutes,
      'earlyDepartureMinutes': earlyDepartureMinutes,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] ?? '',
      employeeId: json['employeeId'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      clockInTime: json['clockInTime'] != null 
          ? DateTime.parse(json['clockInTime']) 
          : null,
      clockOutTime: json['clockOutTime'] != null 
          ? DateTime.parse(json['clockOutTime']) 
          : null,
      status: json['status'] ?? '',
      clockInLatitude: json['clockInLatitude']?.toDouble(),
      clockInLongitude: json['clockInLongitude']?.toDouble(),
      clockOutLatitude: json['clockOutLatitude']?.toDouble(),
      clockOutLongitude: json['clockOutLongitude']?.toDouble(),
      isWithinRadius: json['isWithinRadius'] ?? false,
      lateMinutes: json['lateMinutes'] ?? 0,
      earlyDepartureMinutes: json['earlyDepartureMinutes'] ?? 0,
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  @override
  String toString() {
    return 'AttendanceRecord(id: $id, employeeId: $employeeId, date: $date, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttendanceRecord && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}

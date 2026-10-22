import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'employee_model.g.dart';

@HiveType(typeId: 0)
class Employee {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String employeeId;
  
  @HiveField(2)
  final String firstName;
  
  @HiveField(3)
  final String lastName;
  
  @HiveField(4)
  final String email;
  
  @HiveField(5)
  final String phone;
  
  @HiveField(6)
  final String role;
  
  @HiveField(7)
  final String department;
  
  @HiveField(8)
  final String position;
  
  @HiveField(9)
  final DateTime hireDate;
  
  @HiveField(10)
  final String companyId;
  
  @HiveField(11)
  final String assignedLocationId;
  
  @HiveField(12)
  final TimeOfDay checkInTime;
  
  @HiveField(13)
  final TimeOfDay checkOutTime;
  
  @HiveField(14)
  final bool isActive;
  
  @HiveField(15)
  final String? profileImage;
  
  @HiveField(16)
  final DateTime createdAt;
  
  @HiveField(17)
  final DateTime updatedAt;

  Employee({
    required this.id,
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    required this.department,
    required this.position,
    required this.hireDate,
    required this.companyId,
    required this.assignedLocationId,
    required this.checkInTime,
    required this.checkOutTime,
    this.isActive = true,
    this.profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  String get fullName => '$firstName $lastName';
  
  Employee copyWith({
    String? id,
    String? employeeId,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? role,
    String? department,
    String? position,
    DateTime? hireDate,
    String? companyId,
    String? assignedLocationId,
    TimeOfDay? checkInTime,
    TimeOfDay? checkOutTime,
    bool? isActive,
    String? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Employee(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      department: department ?? this.department,
      position: position ?? this.position,
      hireDate: hireDate ?? this.hireDate,
      companyId: companyId ?? this.companyId,
      assignedLocationId: assignedLocationId ?? this.assignedLocationId,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      isActive: isActive ?? this.isActive,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'role': role,
      'department': department,
      'position': position,
      'hireDate': hireDate.toIso8601String(),
      'companyId': companyId,
      'assignedLocationId': assignedLocationId,
      'checkInTime': {'hour': checkInTime.hour, 'minute': checkInTime.minute},
      'checkOutTime': {'hour': checkOutTime.hour, 'minute': checkOutTime.minute},
      'isActive': isActive,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? '',
      employeeId: json['employeeId'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      department: json['department'] ?? '',
      position: json['position'] ?? '',
      hireDate: DateTime.parse(json['hireDate'] ?? DateTime.now().toIso8601String()),
      companyId: json['companyId'] ?? '',
      assignedLocationId: json['assignedLocationId'] ?? '',
      checkInTime: TimeOfDay(
        hour: json['checkInTime']['hour'] ?? 9,
        minute: json['checkInTime']['minute'] ?? 0,
      ),
      checkOutTime: TimeOfDay(
        hour: json['checkOutTime']['hour'] ?? 17,
        minute: json['checkOutTime']['minute'] ?? 0,
      ),
      isActive: json['isActive'] ?? true,
      profileImage: json['profileImage'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  @override
  String toString() {
    return 'Employee(id: $id, employeeId: $employeeId, fullName: $fullName, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Employee && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}

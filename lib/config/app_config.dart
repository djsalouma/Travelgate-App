import 'package:flutter/material.dart';

class AppConfig {
  static const String appName = 'TravelGate Attendance';
  static const String appVersion = '1.0.0';
  
  // Colors
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color secondaryColor = Color(0xFF1E40AF);
  static const Color accentColor = Color(0xFF3B82F6);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF06B6D4);
  
  // Location settings
  static const double geofenceRadius = 1000.0; // 1 kilometer in meters
  static const int locationCheckInterval = 30; // seconds
  static const int clockInGracePeriod = 15; // minutes
  static const int clockOutGracePeriod = 15; // minutes
  
  // Working hours (can be customized per employee)
  static const TimeOfDay defaultCheckInTime = TimeOfDay(hour: 9, minute: 0);
  static const TimeOfDay defaultCheckOutTime = TimeOfDay(hour: 17, minute: 0);
  
  // API endpoints (if using backend)
  static const String baseUrl = 'https://your-api-url.com/api';
  static const String loginEndpoint = '/auth/login';
  static const String employeesEndpoint = '/employees';
  static const String attendanceEndpoint = '/attendance';
  static const String reportsEndpoint = '/reports';
  
  // Storage keys
  static const String userTokenKey = 'user_token';
  static const String userRoleKey = 'user_role';
  static const String userIdKey = 'user_id';
  static const String companyIdKey = 'company_id';
  static const String companyLocationKey = 'company_location';
  
  // Roles
  static const String roleAdmin = 'admin';
  static const String roleEmployee = 'employee';
  static const String roleManager = 'manager';
  
  // Attendance status
  static const String statusPresent = 'Present';
  static const String statusAbsent = 'Absent';
  static const String statusLate = 'Late';
  static const String statusEarlyDeparture = 'Early Departure';
  static const String statusOnTime = 'On Time';
  
  // Notification channels
  static const String notificationChannelId = 'attendance_channel';
  static const String notificationChannelName = 'Attendance Notifications';
  static const String notificationChannelDescription = 'Notifications for attendance tracking';
}

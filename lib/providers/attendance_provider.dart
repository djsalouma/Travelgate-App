import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../config/app_config.dart';
import '../models/attendance_model.dart';
import '../models/employee_model.dart';
import '../models/location_model.dart';
import 'location_provider.dart';

class AttendanceProvider with ChangeNotifier {
  List<AttendanceRecord> _attendanceRecords = [];
  bool _isLoading = false;
  String? _errorMessage;
  AttendanceRecord? _currentDayRecord;
  
  // Hive box name
  static const String _boxName = 'attendance_records';

  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AttendanceRecord? get currentDayRecord => _currentDayRecord;

  AttendanceProvider() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final box = await Hive.openBox<AttendanceRecord>(_boxName);
      _attendanceRecords = box.values.toList();
      _updateCurrentDayRecord();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load attendance records: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final box = await Hive.openBox<AttendanceRecord>(_boxName);
      await box.clear();
      for (final record in _attendanceRecords) {
        await box.add(record);
      }
    } catch (e) {
      _errorMessage = 'Failed to save attendance records: ${e.toString()}';
      notifyListeners();
    }
  }

  void _updateCurrentDayRecord() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    _currentDayRecord = _attendanceRecords.firstWhere(
      (record) => record.date.isAfter(todayStart) && record.date.isBefore(todayEnd),
      orElse: () => null,
    );
  }

  Future<bool> clockIn(Employee employee, LocationProvider locationProvider) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if already clocked in today
      if (_currentDayRecord?.clockInTime != null) {
        _errorMessage = 'You have already clocked in today';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check location
      final isWithinRadius = await locationProvider.checkLocationAndClockIn();
      if (!isWithinRadius) {
        _errorMessage = 'You are not within the company location radius';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create new attendance record or update existing
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      AttendanceRecord record;
      if (_currentDayRecord == null) {
        // Create new record
        record = AttendanceRecord(
          id: const Uuid().v4(),
          employeeId: employee.id,
          date: today,
          clockInTime: now,
          clockInLatitude: locationProvider.currentPosition?.latitude,
          clockInLongitude: locationProvider.currentPosition?.longitude,
          isWithinRadius: true,
          status: AppConfig.statusPresent,
        );
        _attendanceRecords.add(record);
      } else {
        // Update existing record
        record = _currentDayRecord!.copyWith(
          clockInTime: now,
          clockInLatitude: locationProvider.currentPosition?.latitude,
          clockInLongitude: locationProvider.currentPosition?.longitude,
          isWithinRadius: true,
          status: AppConfig.statusPresent,
        );
        final index = _attendanceRecords.indexOf(_currentDayRecord!);
        _attendanceRecords[index] = record;
      }

      _currentDayRecord = record;
      await _saveToStorage();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to clock in: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> clockOut(Employee employee, LocationProvider locationProvider) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if clocked in
      if (_currentDayRecord == null || _currentDayRecord!.clockInTime == null) {
        _errorMessage = 'You have not clocked in today';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check if already clocked out
      if (_currentDayRecord!.clockOutTime != null) {
        _errorMessage = 'You have already clocked out today';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check location
      final isWithinRadius = await locationProvider.checkLocationAndClockOut();
      
      // For clock out, we might allow it even if not in radius
      // depending on business logic
      
      final now = DateTime.now();
      final record = _currentDayRecord!.copyWith(
        clockOutTime: now,
        clockOutLatitude: locationProvider.currentPosition?.latitude,
        clockOutLongitude: locationProvider.currentPosition?.longitude,
        isWithinRadius: isWithinRadius,
      );

      // Calculate late minutes and early departure
      final lateMinutes = _calculateLateMinutes(employee, record);
      final earlyMinutes = _calculateEarlyDepartureMinutes(employee, record);
      
      final updatedRecord = record.copyWith(
        lateMinutes: lateMinutes,
        earlyDepartureMinutes: earlyMinutes,
        status: _determineStatus(lateMinutes, earlyMinutes, isWithinRadius),
      );

      final index = _attendanceRecords.indexOf(_currentDayRecord!);
      _attendanceRecords[index] = updatedRecord;
      _currentDayRecord = updatedRecord;
      
      await _saveToStorage();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to clock out: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  int _calculateLateMinutes(Employee employee, AttendanceRecord record) {
    if (record.clockInTime == null) return 0;
    
    // Get scheduled check-in time
    final scheduledTime = DateTime(
      record.date.year,
      record.date.month,
      record.date.day,
      employee.checkInTime.hour,
      employee.checkInTime.minute,
    );
    
    // Add grace period
    final scheduledTimeWithGrace = scheduledTime.add(
      Duration(minutes: AppConfig.clockInGracePeriod),
    );
    
    if (record.clockInTime!.isAfter(scheduledTimeWithGrace)) {
      return record.clockInTime!.difference(scheduledTimeWithGrace).inMinutes;
    }
    
    return 0;
  }

  int _calculateEarlyDepartureMinutes(Employee employee, AttendanceRecord record) {
    if (record.clockOutTime == null) return 0;
    
    // Get scheduled check-out time
    final scheduledTime = DateTime(
      record.date.year,
      record.date.month,
      record.date.day,
      employee.checkOutTime.hour,
      employee.checkOutTime.minute,
    );
    
    // Subtract grace period
    final scheduledTimeWithGrace = scheduledTime.subtract(
      Duration(minutes: AppConfig.clockOutGracePeriod),
    );
    
    if (record.clockOutTime!.isBefore(scheduledTimeWithGrace)) {
      return scheduledTimeWithGrace.difference(record.clockOutTime!).inMinutes;
    }
    
    return 0;
  }

  String _determineStatus(int lateMinutes, int earlyMinutes, bool isWithinRadius) {
    if (!isWithinRadius) {
      return AppConfig.statusAbsent;
    }
    
    if (lateMinutes > 0 && earlyMinutes > 0) {
      return '${AppConfig.statusLate} & ${AppConfig.statusEarlyDeparture}';
    } else if (lateMinutes > 0) {
      return AppConfig.statusLate;
    } else if (earlyMinutes > 0) {
      return AppConfig.statusEarlyDeparture;
    }
    
    return AppConfig.statusOnTime;
  }

  Future<List<AttendanceRecord>> getAttendanceRecordsForEmployee(
    String employeeId,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      List<AttendanceRecord> filtered = _attendanceRecords
          .where((record) => record.employeeId == employeeId)
          .toList();

      if (startDate != null) {
        filtered = filtered.where((record) => 
          record.date.isAfter(startDate) || record.date == startDate
        ).toList();
      }

      if (endDate != null) {
        filtered = filtered.where((record) => 
          record.date.isBefore(endDate) || record.date == endDate
        ).toList();
      }

      filtered.sort((a, b) => b.date.compareTo(a.date));
      
      _isLoading = false;
      notifyListeners();
      return filtered;
    } catch (e) {
      _errorMessage = 'Failed to get attendance records: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  Future<List<AttendanceRecord>> getAllAttendanceRecords(
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      List<AttendanceRecord> filtered = List.from(_attendanceRecords);

      if (startDate != null) {
        filtered = filtered.where((record) => 
          record.date.isAfter(startDate) || record.date == startDate
        ).toList();
      }

      if (endDate != null) {
        filtered = filtered.where((record) => 
          record.date.isBefore(endDate) || record.date == endDate
        ).toList();
      }

      filtered.sort((a, b) => b.date.compareTo(a.date));
      
      _isLoading = false;
      notifyListeners();
      return filtered;
    } catch (e) {
      _errorMessage = 'Failed to get all attendance records: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  Future<void> addManualAttendance(AttendanceRecord record) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _attendanceRecords.add(record);
      await _saveToStorage();
      _updateCurrentDayRecord();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add manual attendance: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAttendance(AttendanceRecord record) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final index = _attendanceRecords.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        _attendanceRecords[index] = record;
        await _saveToStorage();
        _updateCurrentDayRecord();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update attendance: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAttendance(String recordId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _attendanceRecords.removeWhere((record) => record.id == recordId);
      await _saveToStorage();
      _updateCurrentDayRecord();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete attendance: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get attendance statistics for an employee
  Map<String, dynamic> getEmployeeAttendanceStats(String employeeId) {
    final records = _attendanceRecords
        .where((record) => record.employeeId == employeeId)
        .toList();

    if (records.isEmpty) {
      return {
        'totalDays': 0,
        'presentDays': 0,
        'absentDays': 0,
        'lateDays': 0,
        'earlyDepartureDays': 0,
        'attendanceRate': 0,
      };
    }

    int presentDays = 0;
    int absentDays = 0;
    int lateDays = 0;
    int earlyDepartureDays = 0;

    for (final record in records) {
      if (record.isFullyPresent) presentDays++;
      if (record.isAbsent) absentDays++;
      if (record.isLate) lateDays++;
      if (record.isEarlyDeparture) earlyDepartureDays++;
    }

    return {
      'totalDays': records.length,
      'presentDays': presentDays,
      'absentDays': absentDays,
      'lateDays': lateDays,
      'earlyDepartureDays': earlyDepartureDays,
      'attendanceRate': (presentDays / records.length * 100).round(),
    };
  }

  // Get today's attendance status for all employees
  Map<String, AttendanceRecord?> getTodayAttendanceForAllEmployees(List<Employee> employees) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final todayRecords = _attendanceRecords
        .where((record) => 
          record.date.isAfter(todayStart) && record.date.isBefore(todayEnd)
        )
        .toList();

    final result = <String, AttendanceRecord?>{};
    for (final employee in employees) {
      result[employee.id] = todayRecords.firstWhere(
        (record) => record.employeeId == employee.id,
        orElse: () => null,
      );
    }

    return result;
  }
}

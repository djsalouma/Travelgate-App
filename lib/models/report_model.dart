import 'attendance_model.dart';
import 'employee_model.dart';

class AttendanceReport {
  final String reportId;
  final String reportType;
  final DateTime startDate;
  final DateTime endDate;
  final String generatedBy;
  final DateTime generatedAt;
  final List<AttendanceRecord> records;
  final List<Employee> employees;
  final Map<String, dynamic> summary;

  AttendanceReport({
    required this.reportId,
    required this.reportType,
    required this.startDate,
    required this.endDate,
    required this.generatedBy,
    required this.generatedAt,
    required this.records,
    required this.employees,
    required this.summary,
  });

  // Generate summary statistics
  static Map<String, dynamic> generateSummary(
    List<AttendanceRecord> records,
    List<Employee> employees,
  ) {
    final totalEmployees = employees.length;
    final totalRecords = records.length;
    
    // Count by status
    final statusCounts = <String, int>{};
    for (final record in records) {
      statusCounts[record.status] = (statusCounts[record.status] ?? 0) + 1;
    }
    
    // Calculate totals
    int totalPresent = 0;
    int totalAbsent = 0;
    int totalLate = 0;
    int totalEarlyDeparture = 0;
    
    for (final record in records) {
      if (record.isFullyPresent) totalPresent++;
      if (record.isAbsent) totalAbsent++;
      if (record.isLate) totalLate++;
      if (record.isEarlyDeparture) totalEarlyDeparture++;
    }
    
    // Calculate average working hours
    Duration totalWorkingHours = Duration.zero;
    int workingDays = 0;
    for (final record in records) {
      if (record.clockInTime != null && record.clockOutTime != null) {
        totalWorkingHours += record.workingHours;
        workingDays++;
      }
    }
    final avgWorkingHours = workingDays > 0 
        ? totalWorkingHours.inMinutes / workingDays
        : 0;
    
    // Total late minutes
    int totalLateMinutes = 0;
    for (final record in records) {
      totalLateMinutes += record.lateMinutes;
    }
    
    // Total early departure minutes
    int totalEarlyMinutes = 0;
    for (final record in records) {
      totalEarlyMinutes += record.earlyDepartureMinutes;
    }
    
    return {
      'totalEmployees': totalEmployees,
      'totalRecords': totalRecords,
      'statusCounts': statusCounts,
      'totalPresent': totalPresent,
      'totalAbsent': totalAbsent,
      'totalLate': totalLate,
      'totalEarlyDeparture': totalEarlyDeparture,
      'avgWorkingHoursMinutes': avgWorkingHours,
      'totalLateMinutes': totalLateMinutes,
      'totalEarlyMinutes': totalEarlyMinutes,
      'attendanceRate': totalRecords > 0 
          ? (totalPresent / totalRecords * 100).round()
          : 0,
      'absenteeismRate': totalRecords > 0 
          ? (totalAbsent / totalRecords * 100).round()
          : 0,
    };
  }

  // Generate employee-wise report
  static Map<String, dynamic> generateEmployeeReport(
    String employeeId,
    List<AttendanceRecord> records,
    Employee employee,
  ) {
    final employeeRecords = records.where(
      (record) => record.employeeId == employeeId,
    ).toList();
    
    int totalDays = employeeRecords.length;
    int presentDays = employeeRecords.where((r) => r.isFullyPresent).length;
    int absentDays = employeeRecords.where((r) => r.isAbsent).length;
    int lateDays = employeeRecords.where((r) => r.isLate).length;
    int earlyDepartureDays = employeeRecords.where((r) => r.isEarlyDeparture).length;
    
    Duration totalWorkingHours = Duration.zero;
    int totalLateMinutes = 0;
    int totalEarlyMinutes = 0;
    
    for (final record in employeeRecords) {
      totalWorkingHours += record.workingHours;
      totalLateMinutes += record.lateMinutes;
      totalEarlyMinutes += record.earlyDepartureMinutes;
    }
    
    return {
      'employeeId': employeeId,
      'employeeName': employee.fullName,
      'department': employee.department,
      'position': employee.position,
      'totalDays': totalDays,
      'presentDays': presentDays,
      'absentDays': absentDays,
      'lateDays': lateDays,
      'earlyDepartureDays': earlyDepartureDays,
      'totalWorkingHours': totalWorkingHours.inMinutes,
      'totalLateMinutes': totalLateMinutes,
      'totalEarlyMinutes': totalEarlyMinutes,
      'attendanceRate': totalDays > 0 ? (presentDays / totalDays * 100).round() : 0,
      'punctualityRate': totalDays > 0 
          ? ((presentDays + (totalDays - lateDays)) / totalDays * 100).round()
          : 0,
    };
  }
}

// Report types
class ReportType {
  static const String daily = 'daily';
  static const String weekly = 'weekly';
  static const String monthly = 'monthly';
  static const String yearly = 'yearly';
  static const String custom = 'custom';
  
  static List<String> get all => [daily, weekly, monthly, yearly, custom];
  
  static String getDisplayName(String type) {
    switch (type) {
      case daily:
        return 'Daily Report';
      case weekly:
        return 'Weekly Report';
      case monthly:
        return 'Monthly Report';
      case yearly:
        return 'Yearly Report';
      case custom:
        return 'Custom Report';
      default:
        return type;
    }
  }
}

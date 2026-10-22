import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:share_plus/share_plus.dart';

import '../models/attendance_model.dart';
import '../models/employee_model.dart';
import '../models/report_model.dart';

class ExcelExportService {
  // Export attendance records to Excel
  static Future<File?> exportAttendanceRecords({
    required List<AttendanceRecord> records,
    required List<Employee> employees,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Create Excel workbook
      final workbook = Excel.createExcel();
      final sheet = workbook['Attendance Records'];

      // Add headers
      sheet.appendRow([
        'Employee ID',
        'Employee Name',
        'Date',
        'Clock In Time',
        'Clock Out Time',
        'Status',
        'Working Hours',
        'Late Minutes',
        'Early Departure Minutes',
        'Within Radius',
      ]);

      // Add data rows
      for (final record in records) {
        final employee = employees.firstWhere(
          (e) => e.id == record.employeeId,
          orElse: () => Employee(
            id: '',
            employeeId: record.employeeId,
            firstName: 'Unknown',
            lastName: '',
            email: '',
            phone: '',
            role: '',
            department: '',
            position: '',
            hireDate: DateTime.now(),
            companyId: '',
            assignedLocationId: '',
            checkInTime: TimeOfDay(hour: 9, minute: 0),
            checkOutTime: TimeOfDay(hour: 17, minute: 0),
          ),
        );

        final workingHours = record.workingHours.inMinutes;
        final hours = workingHours ~/ 60;
        final minutes = workingHours % 60;

        sheet.appendRow([
          employee.employeeId,
          employee.fullName,
          record.date.toString().split(' ')[0], // Date only
          record.clockInTime?.toString().split(' ')[1] ?? 'N/A',
          record.clockOutTime?.toString().split(' ')[1] ?? 'N/A',
          record.status,
          '$hours hours $minutes minutes',
          record.lateMinutes,
          record.earlyDepartureMinutes,
          record.isWithinRadius ? 'Yes' : 'No',
        ]);
      }

      // Save the file
      final file = await _saveExcelFile(workbook, 'attendance_records', startDate, endDate);
      return file;
    } catch (e) {
      print('Failed to export attendance records: ${e.toString()}');
      return null;
    }
  }

  // Export employee report to Excel
  static Future<File?> exportEmployeeReport({
    required Map<String, dynamic> reportData,
    required List<AttendanceRecord> records,
    required Employee employee,
  }) async {
    try {
      final workbook = Excel.createExcel();
      
      // Summary sheet
      final summarySheet = workbook['Summary'];
      summarySheet.appendRow(['Employee Attendance Report']);
      summarySheet.appendRow([]);
      summarySheet.appendRow(['Employee Name:', reportData['employeeName']]);
      summarySheet.appendRow(['Employee ID:', reportData['employeeId']]);
      summarySheet.appendRow(['Department:', reportData['department']]);
      summarySheet.appendRow(['Position:', reportData['position']]);
      summarySheet.appendRow([]);
      summarySheet.appendRow(['Attendance Statistics']);
      summarySheet.appendRow(['Total Days:', reportData['totalDays']]);
      summarySheet.appendRow(['Present Days:', reportData['presentDays']]);
      summarySheet.appendRow(['Absent Days:', reportData['absentDays']]);
      summarySheet.appendRow(['Late Days:', reportData['lateDays']]);
      summarySheet.appendRow(['Early Departure Days:', reportData['earlyDepartureDays']]);
      summarySheet.appendRow([]);
      summarySheet.appendRow(['Attendance Rate:', '${reportData['attendanceRate']}%']);

      // Detailed records sheet
      final recordsSheet = workbook['Detailed Records'];
      recordsSheet.appendRow([
        'Date',
        'Clock In Time',
        'Clock Out Time',
        'Status',
        'Working Hours',
        'Late Minutes',
        'Early Departure Minutes',
      ]);

      for (final record in records) {
        final workingHours = record.workingHours.inMinutes;
        final hours = workingHours ~/ 60;
        final minutes = workingHours % 60;

        recordsSheet.appendRow([
          record.date.toString().split(' ')[0],
          record.clockInTime?.toString().split(' ')[1] ?? 'N/A',
          record.clockOutTime?.toString().split(' ')[1] ?? 'N/A',
          record.status,
          '$hours hours $minutes minutes',
          record.lateMinutes,
          record.earlyDepartureMinutes,
        ]);
      }

      final file = await _saveExcelFile(
        workbook, 
        'employee_report_${employee.employeeId}',
        null,
        null,
      );
      return file;
    } catch (e) {
      print('Failed to export employee report: ${e.toString()}');
      return null;
    }
  }

  // Export all employees attendance summary
  static Future<File?> exportAllEmployeesSummary({
    required Map<String, dynamic> summary,
    required List<Map<String, dynamic>> employeeStats,
  }) async {
    try {
      final workbook = Excel.createExcel();
      
      // Summary sheet
      final summarySheet = workbook['Summary'];
      summarySheet.appendRow(['Company Attendance Summary']);
      summarySheet.appendRow([]);
      summarySheet.appendRow(['Period:', 'All Time']);
      summarySheet.appendRow([]);
      summarySheet.appendRow(['Total Employees:', summary['totalEmployees']]);
      summarySheet.appendRow(['Total Records:', summary['totalRecords']]);
      summarySheet.appendRow([]);
      summarySheet.appendRow(['Attendance Rate:', '${summary['attendanceRate']}%']);
      summarySheet.appendRow(['Absenteeism Rate:', '${summary['absenteeismRate']}%']);
      summarySheet.appendRow([]);
      summarySheet.appendRow(['Present Days:', summary['totalPresent']]);
      summarySheet.appendRow(['Absent Days:', summary['totalAbsent']]);
      summarySheet.appendRow(['Late Days:', summary['totalLate']]);
      summarySheet.appendRow(['Early Departure Days:', summary['totalEarlyDeparture']]);

      // Employee details sheet
      final employeesSheet = workbook['Employee Details'];
      employeesSheet.appendRow([
        'Employee ID',
        'Employee Name',
        'Department',
        'Position',
        'Total Days',
        'Present Days',
        'Absent Days',
        'Late Days',
        'Early Departure Days',
        'Attendance Rate',
      ]);

      for (final stats in employeeStats) {
        employeesSheet.appendRow([
          stats['employeeId'],
          stats['employeeName'],
          stats['department'],
          stats['position'],
          stats['totalDays'],
          stats['presentDays'],
          stats['absentDays'],
          stats['lateDays'],
          stats['earlyDepartureDays'],
          '${stats['attendanceRate']}%',
        ]);
      }

      final file = await _saveExcelFile(workbook, 'company_attendance_summary', null, null);
      return file;
    } catch (e) {
      print('Failed to export company summary: ${e.toString()}');
      return null;
    }
  }

  // Save Excel file to device
  static Future<File> _saveExcelFile(
    Excel workbook,
    String fileName,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    // Generate file name with dates if provided
    final dateSuffix = startDate != null && endDate != null
        ? '_${startDate.toString().split(' ')[0]}_to_${endDate.toString().split(' ')[0]}'
        : '';
    
    final fullFileName = '$fileName$dateSuffix.xlsx';

    // Get downloads directory
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : Platform.isIOS
            ? await getApplicationDocumentsDirectory()
            : await getDownloadsDirectory();

    final filePath = '${directory?.path}/$fullFileName';
    final file = File(filePath);

    // Save the Excel file
    final bytes = workbook.save();
    await file.writeAsBytes(bytes!);

    return file;
  }

  // Share Excel file
  static Future<void> shareExcelFile(File file) async {
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
      text: 'Attendance Report',
    );
  }

  // Export and share attendance records
  static Future<bool> exportAndShareAttendanceRecords({
    required List<AttendanceRecord> records,
    required List<Employee> employees,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final file = await exportAttendanceRecords(
      records: records,
      employees: employees,
      startDate: startDate,
      endDate: endDate,
    );

    if (file != null) {
      await shareExcelFile(file);
      return true;
    }
    return false;
  }

  // Export and share employee report
  static Future<bool> exportAndShareEmployeeReport({
    required Map<String, dynamic> reportData,
    required List<AttendanceRecord> records,
    required Employee employee,
  }) async {
    final file = await exportEmployeeReport(
      reportData: reportData,
      records: records,
      employee: employee,
    );

    if (file != null) {
      await shareExcelFile(file);
      return true;
    }
    return false;
  }

  // Export and share company summary
  static Future<bool> exportAndShareCompanySummary({
    required Map<String, dynamic> summary,
    required List<Map<String, dynamic>> employeeStats,
  }) async {
    final file = await exportAllEmployeesSummary(
      summary: summary,
      employeeStats: employeeStats,
    );

    if (file != null) {
      await shareExcelFile(file);
      return true;
    }
    return false;
  }
}

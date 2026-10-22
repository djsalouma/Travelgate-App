import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../config/app_config.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/employee_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../services/excel_export_service.dart';
import '../../models/report_model.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedReportType = ReportType.daily;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String? _selectedEmployeeId;

  @override
  void initState() {
    super.initState();
    // Set default date range based on report type
    _updateDateRange();
  }

  void _updateDateRange() {
    final now = DateTime.now();
    
    switch (_selectedReportType) {
      case ReportType.daily:
        _selectedStartDate = DateTime(now.year, now.month, now.day);
        _selectedEndDate = DateTime(now.year, now.month, now.day);
        break;
      case ReportType.weekly:
        // Start from Monday
        _selectedStartDate = now.subtract(Duration(days: now.weekday - 1));
        _selectedEndDate = _selectedStartDate!.add(const Duration(days: 6));
        break;
      case ReportType.monthly:
        _selectedStartDate = DateTime(now.year, now.month, 1);
        _selectedEndDate = DateTime(now.year, now.month + 1, 0);
        break;
      case ReportType.yearly:
        _selectedStartDate = DateTime(now.year, 1, 1);
        _selectedEndDate = DateTime(now.year, 12, 31);
        break;
      default:
        _selectedStartDate = DateTime(now.year, now.month, 1);
        _selectedEndDate = DateTime(now.year, now.month + 1, 0);
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: _selectedStartDate ?? DateTime.now(),
        end: _selectedEndDate ?? DateTime.now(),
      ),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppConfig.primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
      });
    }
  }

  Future<void> _generateReport() async {
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);

    if (_selectedStartDate == null || _selectedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date range'),
          backgroundColor: AppConfig.errorColor,
        ),
      );
      return;
    }

    // Get data
    final allRecords = await attendanceProvider.getAllAttendanceRecords(
      _selectedStartDate,
      _selectedEndDate,
    );
    
    final allEmployees = employeeProvider.employees;
    
    // Generate summary
    final summary = AttendanceReport.generateSummary(allRecords, allEmployees);

    // Generate report
    final report = AttendanceReport(
      reportId: DateTime.now().millisecondsSinceEpoch.toString(),
      reportType: _selectedReportType,
      startDate: _selectedStartDate!,
      endDate: _selectedEndDate!,
      generatedBy: 'Admin',
      generatedAt: DateTime.now(),
      records: allRecords,
      employees: allEmployees,
      summary: summary,
    );

    // Export to Excel
    if (_selectedEmployeeId == null) {
      // Export all employees report
      final employeeStats = allEmployees.map((employee) {
        return AttendanceReport.generateEmployeeReport(
          employee.id,
          allRecords.where((r) => r.employeeId == employee.id).toList(),
          employee,
        );
      }).toList();

      final success = await ExcelExportService.exportAndShareCompanySummary(
        summary: summary,
        employeeStats: employeeStats,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Company attendance report exported successfully!'),
            backgroundColor: AppConfig.successColor,
          ),
        );
      }
    } else {
      // Export single employee report
      final employee = allEmployees.firstWhere((e) => e.id == _selectedEmployeeId);
      final employeeRecords = allRecords.where((r) => r.employeeId == _selectedEmployeeId).toList();
      final reportData = AttendanceReport.generateEmployeeReport(
        _selectedEmployeeId!,
        employeeRecords,
        employee,
      );

      final success = await ExcelExportService.exportAndShareEmployeeReport(
        reportData: reportData,
        records: employeeRecords,
        employee: employee,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employee attendance report exported successfully!'),
            backgroundColor: AppConfig.successColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final employeeProvider = Provider.of<EmployeeProvider>(context);
    final attendanceProvider = Provider.of<AttendanceProvider>(context);

    return LoadingOverlay(
      isLoading: employeeProvider.isLoading || attendanceProvider.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reports'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Report Type Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Report Type',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ReportType.all.map((type) {
                          return ChoiceChip(
                            label: Text(ReportType.getDisplayName(type)),
                            selected: _selectedReportType == type,
                            onSelected: (selected) {
                              setState(() {
                                _selectedReportType = type;
                                _selectedEmployeeId = null; // Reset employee filter
                                _updateDateRange();
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Date Range
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Date Range',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      TextButton.icon(
                        onPressed: () => _selectDateRange(context),
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _selectedStartDate != null && _selectedEndDate != null
                              ? '${DateFormat('MMM d, y').format(_selectedStartDate!)} - ${DateFormat('MMM d, y').format(_selectedEndDate!)}'
                              : 'Select Date Range',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Employee Filter
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Employee Filter',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      FutureBuilder(
                        future: employeeProvider.initializeWithMockData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final employees = employeeProvider.employees;
                          
                          return DropdownButtonFormField<String?>(
                            value: _selectedEmployeeId,
                            hint: const Text('All Employees'),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('All Employees'),
                              ),
                              ...employees.map((employee) {
                                return DropdownMenuItem<String?>(
                                  value: employee.id,
                                  child: Text('${employee.fullName} (${employee.employeeId})'),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedEmployeeId = value;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Select Employee',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Summary Preview
              FutureBuilder(
                future: _selectedEmployeeId == null
                    ? attendanceProvider.getAllAttendanceRecords(
                        _selectedStartDate,
                        _selectedEndDate,
                      )
                    : attendanceProvider.getAttendanceRecordsForEmployee(
                        _selectedEmployeeId!,
                        _selectedStartDate,
                        _selectedEndDate,
                      ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No data available for selected range'),
                      ),
                    );
                  }

                  final records = snapshot.data!;
                  final allEmployees = employeeProvider.employees;
                  
                  if (_selectedEmployeeId == null) {
                    // All employees summary
                    final summary = AttendanceReport.generateSummary(records, allEmployees);
                    return _buildSummaryPreview(summary, isCompany: true);
                  } else {
                    // Single employee summary
                    final employee = allEmployees.firstWhere((e) => e.id == _selectedEmployeeId);
                    final summary = AttendanceReport.generateEmployeeReport(
                      _selectedEmployeeId!,
                      records,
                      employee,
                    );
                    return _buildSummaryPreview(summary, isCompany: false);
                  }
                },
              ),
              const SizedBox(height: 24),
              
              // Generate Report Button
              ElevatedButton(
                onPressed: _generateReport,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text(
                      'GENERATE REPORT',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryPreview(Map<String, dynamic> summary, {required bool isCompany}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isCompany ? 'Company Attendance Summary' : 'Employee Attendance Summary',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            if (isCompany) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      'Total Employees',
                      summary['totalEmployees'].toString(),
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      'Total Records',
                      summary['totalRecords'].toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Present',
                    summary['totalPresent'].toString(),
                    AppConfig.successColor,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Absent',
                    summary['totalAbsent'].toString(),
                    AppConfig.errorColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Late',
                    summary['totalLate'].toString(),
                    AppConfig.warningColor,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Early Departure',
                    summary['totalEarlyDeparture'].toString(),
                    AppConfig.infoColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Attendance Rate',
                    '${summary['attendanceRate']}%',
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Absenteeism Rate',
                    '${summary['absenteeismRate']}%',
                  ),
                ),
              ],
            ),
            
            if (!isCompany)
              Column(
                children: [
                  const SizedBox(height: 12),
                  _buildSummaryItem(
                    'Punctuality Rate',
                    '${summary['punctualityRate']}%',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class ReportDetailScreen extends StatelessWidget {
  final String reportType;

  const ReportDetailScreen({super.key, required this.reportType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ReportType.getDisplayName(reportType)),
      ),
      body: Center(
        child: Text('Report details for ${ReportType.getDisplayName(reportType)}'),
      ),
    );
  }
}

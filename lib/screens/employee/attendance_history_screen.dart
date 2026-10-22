import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../services/excel_export_service.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    // Set default date range to current month
    final now = DateTime.now();
    _selectedStartDate = DateTime(now.year, now.month, 1);
    _selectedEndDate = DateTime(now.year, now.month + 1, 0);
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

  Future<void> _exportToExcel() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    final employee = authProvider.currentUser!;

    final records = await attendanceProvider.getAttendanceRecordsForEmployee(
      employee.id,
      _selectedStartDate,
      _selectedEndDate,
    );

    final success = await ExcelExportService.exportAndShareAttendanceRecords(
      records: records,
      employees: [employee],
      startDate: _selectedStartDate,
      endDate: _selectedEndDate,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance records exported successfully!'),
          backgroundColor: AppConfig.successColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to export attendance records'),
          backgroundColor: AppConfig.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final employee = authProvider.currentUser!;

    return LoadingOverlay(
      isLoading: attendanceProvider.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Attendance History'),
          actions: [
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _exportToExcel,
              tooltip: 'Export to Excel',
            ),
          ],
        ),
        body: Column(
          children: [
            // Filters
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Date Range
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => _selectDateRange(context),
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              _selectedStartDate != null && _selectedEndDate != null
                                  ? '${DateFormat('MMM d, y').format(_selectedStartDate!)} - ${DateFormat('MMM d, y').format(_selectedEndDate!)}'
                                  : 'Select Date Range',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Status Filter
                    Row(
                      children: [
                        const Text('Status:'),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            children: [
                              FilterChip(
                                label: const Text('All'),
                                selected: _filter == 'all',
                                onSelected: (selected) {
                                  setState(() {
                                    _filter = 'all';
                                  });
                                },
                              ),
                              FilterChip(
                                label: const Text('Present'),
                                selected: _filter == 'present',
                                onSelected: (selected) {
                                  setState(() {
                                    _filter = 'present';
                                  });
                                },
                              ),
                              FilterChip(
                                label: const Text('Absent'),
                                selected: _filter == 'absent',
                                onSelected: (selected) {
                                  setState(() {
                                    _filter = 'absent';
                                  });
                                },
                              ),
                              FilterChip(
                                label: const Text('Late'),
                                selected: _filter == 'late',
                                onSelected: (selected) {
                                  setState(() {
                                    _filter = 'late';
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Statistics
            FutureBuilder<List<AttendanceRecord>>(
              future: attendanceProvider.getAttendanceRecordsForEmployee(
                employee.id,
                _selectedStartDate,
                _selectedEndDate,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Expanded(
                    child: Center(
                      child: Text('No attendance records found'),
                    ),
                  );
                }

                final records = snapshot.data!;
                final stats = attendanceProvider.getEmployeeAttendanceStats(employee.id);

                // Filter records based on selected filter
                List<AttendanceRecord> filteredRecords = records;
                if (_filter != 'all') {
                  filteredRecords = records.where((record) {
                    switch (_filter) {
                      case 'present':
                        return record.isFullyPresent;
                      case 'absent':
                        return record.isAbsent;
                      case 'late':
                        return record.isLate;
                      default:
                        return true;
                    }
                  }).toList();
                }

                return Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Stats Cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Total Days',
                                stats['totalDays'].toString(),
                                AppConfig.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'Present',
                                stats['presentDays'].toString(),
                                AppConfig.successColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'Absent',
                                stats['absentDays'].toString(),
                                AppConfig.errorColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Late',
                                stats['lateDays'].toString(),
                                AppConfig.warningColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'Early Departure',
                                stats['earlyDepartureDays'].toString(),
                                AppConfig.infoColor,
                              ),
                            ),
                            Expanded(
                              child: _buildStatCard(
                                'Attendance Rate',
                                '${stats['attendanceRate']}%',
                                AppConfig.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Chart
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildAttendanceChart(filteredRecords),
                      ),
                      const SizedBox(height: 16),
                      
                      // Records List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredRecords.length,
                          itemBuilder: (context, index) {
                            final record = filteredRecords[index];
                            return _buildAttendanceRecordItem(record);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceChart(List<AttendanceRecord> records) {
    // Group records by date for the chart
    final dateCounts = <String, int>{};
    for (final record in records) {
      final date = DateFormat('MMM d').format(record.date);
      dateCounts[date] = (dateCounts[date] ?? 0) + 1;
    }

    // Sort by date
    final sortedDates = dateCounts.keys.toList()..sort();

    return SizedBox(
      height: 200,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        series: <CartesianSeries>[
          ColumnSeries<dynamic, String>(
            dataSource: sortedDates.map((date) {
              return {'date': date, 'count': dateCounts[date]};
            }).toList(),
            xValueMapper: (data, _) => data['date'],
            yValueMapper: (data, _) => data['count'],
            color: AppConfig.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceRecordItem(AttendanceRecord record) {
    final statusColor = _getStatusColor(record);
    final workingHours = record.workingHours;
    final hours = workingHours.inHours;
    final minutes = workingHours.inMinutes.remainder(60);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, MMMM d, y').format(record.date),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    record.status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                _buildRecordDetail('Clock In', record.clockInTime),
                const SizedBox(width: 16),
                _buildRecordDetail('Clock Out', record.clockOutTime),
                const SizedBox(width: 16),
                _buildRecordDetail('Hours', '$hours h $minutes m'),
              ],
            ),
            
            if (record.lateMinutes > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Late: ${record.lateMinutes} minutes',
                  style: TextStyle(
                    color: AppConfig.warningColor,
                    fontSize: 14,
                  ),
                ),
              ),
            
            if (record.earlyDepartureMinutes > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Early Departure: ${record.earlyDepartureMinutes} minutes',
                  style: TextStyle(
                    color: AppConfig.infoColor,
                    fontSize: 14,
                  ),
                ),
              ),
            
            if (record.notes != null && record.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Notes: ${record.notes}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordDetail(String label, dynamic value) {
    final displayValue = value is DateTime 
        ? DateFormat('HH:mm').format(value)
        : value?.toString() ?? 'N/A';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          displayValue,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(AttendanceRecord record) {
    if (record.isFullyPresent) {
      return AppConfig.successColor;
    } else if (record.isAbsent) {
      return AppConfig.errorColor;
    } else if (record.isLate) {
      return AppConfig.warningColor;
    } else if (record.isEarlyDeparture) {
      return AppConfig.infoColor;
    }
    return Colors.grey;
  }
}

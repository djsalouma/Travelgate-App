import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../config/app_config.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/employee_provider.dart';
import '../../widgets/common/loading_overlay.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final String employeeId;

  const EmployeeDetailScreen({super.key, required this.employeeId});

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final employeeProvider = Provider.of<EmployeeProvider>(context);
    final attendanceProvider = Provider.of<AttendanceProvider>(context);

    return LoadingOverlay(
      isLoading: employeeProvider.isLoading || attendanceProvider.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Employee Details'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Navigate to edit screen
              },
            ),
          ],
        ),
        body: FutureBuilder(
          future: employeeProvider.getEmployeeById(widget.employeeId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Text('Employee not found'),
              );
            }

            final employee = snapshot.data!;
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Header
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: AppConfig.primaryColor,
                            child: Text(
                              employee.firstName.isNotEmpty
                                  ? employee.firstName[0].toUpperCase()
                                  : 'E',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            employee.fullName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            employee.position,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            employee.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Employee Information
                  const Text(
                    'Employee Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow('Employee ID', employee.employeeId),
                          _buildInfoRow('Department', employee.department),
                          _buildInfoRow('Position', employee.position),
                          _buildInfoRow('Phone', employee.phone),
                          _buildInfoRow('Hire Date', DateFormat('MMM d, y').format(employee.hireDate)),
                          _buildInfoRow('Company ID', employee.companyId),
                          _buildInfoRow('Assigned Location', employee.assignedLocationId),
                          _buildInfoRow('Status', employee.isActive ? 'Active' : 'Inactive'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Working Hours
                  const Text(
                    'Working Hours',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildWorkingHoursItem('Check-In Time', employee.checkInTime.format(context)),
                          _buildWorkingHoursItem('Check-Out Time', employee.checkOutTime.format(context)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Attendance Statistics
                  const Text(
                    'Attendance Statistics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  FutureBuilder<Map<String, dynamic>>(
                    future: Future.value(
                      attendanceProvider.getEmployeeAttendanceStats(employee.id)
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final stats = snapshot.data ?? {
                        'totalDays': 0,
                        'presentDays': 0,
                        'absentDays': 0,
                        'lateDays': 0,
                        'earlyDepartureDays': 0,
                        'attendanceRate': 0,
                      };

                      return Column(
                        children: [
                          Row(
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
                                  'Present Days',
                                  stats['presentDays'].toString(),
                                  AppConfig.successColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Absent Days',
                                  stats['absentDays'].toString(),
                                  AppConfig.errorColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  'Late Days',
                                  stats['lateDays'].toString(),
                                  AppConfig.warningColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Early Departure Days',
                                  stats['earlyDepartureDays'].toString(),
                                  AppConfig.infoColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  'Attendance Rate',
                                  '${stats['attendanceRate']}%',
                                  AppConfig.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Recent Attendance
                  const Text(
                    'Recent Attendance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  FutureBuilder<List<AttendanceRecord>>(
                    future: attendanceProvider.getAttendanceRecordsForEmployee(
                      employee.id,
                      null,
                      null,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No attendance records found'),
                          ),
                        );
                      }

                      final records = snapshot.data!;
                      // Show only last 5 records
                      final recentRecords = records.take(5).toList();

                      return Column(
                        children: recentRecords.map((record) => _buildAttendanceRecordItem(record)).toList(),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // View All Button
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to full attendance history for this employee
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('View Full Attendance History'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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

  Widget _buildWorkingHoursItem(String title, String time) {
    return Column(
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
          time,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceRecordItem(AttendanceRecord record) {
    final statusColor = _getStatusColor(record);

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
                _buildRecordDetail('Hours', '${record.workingHours.inHours}h ${record.workingHours.inMinutes.remainder(60)}m'),
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

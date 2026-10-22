import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../config/app_config.dart';
import '../../models/attendance_model.dart';
import '../../models/employee_model.dart';
import '../../providers/attendance_provider.dart';

class TodayAttendanceList extends StatelessWidget {
  final List<Employee> employees;
  final AttendanceProvider attendanceProvider;

  const TodayAttendanceList({
    super.key,
    required this.employees,
    required this.attendanceProvider,
  });

  @override
  Widget build(BuildContext context) {
    final todayAttendance = attendanceProvider.getTodayAttendanceForAllEmployees(employees);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: employees.map((employee) {
        final record = todayAttendance[employee.id];
        return _buildEmployeeAttendanceItem(employee, record, context);
      }).toList(),
    );
  }

  Widget _buildEmployeeAttendanceItem(
    Employee employee,
    AttendanceRecord? record,
    BuildContext context,
  ) {
    Color statusColor;
    String statusText;
    IconData statusIcon;
    String statusMessage;

    if (record == null) {
      // No record for today
      statusColor = AppConfig.errorColor;
      statusText = 'Absent';
      statusIcon = Icons.error;
      statusMessage = 'No attendance recorded';
    } else if (record.clockOutTime != null) {
      // Clocked out
      statusColor = AppConfig.successColor;
      statusText = 'Clocked Out';
      statusIcon = Icons.check_circle;
      statusMessage = 'Clocked out at ${DateFormat('HH:mm').format(record.clockOutTime!)}';
    } else if (record.clockInTime != null) {
      // Clocked in
      statusColor = AppConfig.primaryColor;
      statusText = 'Clocked In';
      statusIcon = Icons.access_time;
      statusMessage = 'Clocked in at ${DateFormat('HH:mm').format(record.clockInTime!)}';
    } else {
      // Should not happen, but default to absent
      statusColor = AppConfig.errorColor;
      statusText = 'Absent';
      statusIcon = Icons.error;
      statusMessage = 'No attendance recorded';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(
            statusIcon,
            color: statusColor,
            size: 20,
          ),
        ),
        title: Text(
          employee.fullName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${employee.employeeId} - ${employee.position}'),
            Text(
              statusMessage,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ),
        onTap: () {
          // Navigate to employee detail
        },
      ),
    );
  }
}

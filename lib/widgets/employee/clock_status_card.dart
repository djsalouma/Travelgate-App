import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../config/app_config.dart';
import '../../models/attendance_model.dart';
import '../../models/employee_model.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/location_provider.dart';

class ClockStatusCard extends StatelessWidget {
  final Employee employee;
  final AttendanceRecord? attendanceRecord;

  const ClockStatusCard({
    super.key,
    required this.employee,
    this.attendanceRecord,
  });

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    
    final isClockedIn = attendanceRecord?.clockInTime != null && 
                       attendanceRecord?.clockOutTime == null;
    final isClockedOut = attendanceRecord?.clockOutTime != null;
    final isWithinRadius = locationProvider.isWithinRadius;

    Color statusColor;
    String statusText;
    IconData statusIcon;
    String statusMessage;

    if (isClockedOut) {
      statusColor = AppConfig.successColor;
      statusText = 'Clocked Out';
      statusIcon = Icons.check_circle;
      statusMessage = 'You have successfully clocked out for today';
    } else if (isClockedIn) {
      statusColor = AppConfig.primaryColor;
      statusText = 'Clocked In';
      statusIcon = Icons.access_time;
      statusMessage = 'You are currently clocked in';
    } else {
      if (isWithinRadius) {
        statusColor = AppConfig.warningColor;
        statusText = 'Ready to Clock In';
        statusIcon = Icons.login;
        statusMessage = 'Tap below to clock in for today';
      } else {
        statusColor = AppConfig.errorColor;
        statusText = 'Outside Radius';
        statusIcon = Icons.error;
        statusMessage = 'You must be within the company radius to clock in';
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  statusIcon,
                  color: statusColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Clock Status',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Text(
              statusText,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 4),
            
            Text(
              statusMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            
            if (isClockedIn && attendanceRecord?.clockInTime != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Clocked in at: ${DateFormat('HH:mm').format(attendanceRecord!.clockInTime!)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

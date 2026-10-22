import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../providers/attendance_provider.dart';

class AttendanceStatsCard extends StatelessWidget {
  final String employeeId;
  final AttendanceProvider attendanceProvider;

  const AttendanceStatsCard({
    super.key,
    required this.employeeId,
    required this.attendanceProvider,
  });

  @override
  Widget build(BuildContext context) {
    final stats = attendanceProvider.getEmployeeAttendanceStats(employeeId);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: AppConfig.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Attendance Statistics',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatItem(
                  'Total Days',
                  stats['totalDays'].toString(),
                  AppConfig.primaryColor,
                ),
                _buildStatItem(
                  'Present',
                  stats['presentDays'].toString(),
                  AppConfig.successColor,
                ),
                _buildStatItem(
                  'Absent',
                  stats['absentDays'].toString(),
                  AppConfig.errorColor,
                ),
                _buildStatItem(
                  'Late',
                  stats['lateDays'].toString(),
                  AppConfig.warningColor,
                ),
                _buildStatItem(
                  'Early Departure',
                  stats['earlyDepartureDays'].toString(),
                  AppConfig.infoColor,
                ),
                _buildStatItem(
                  'Attendance Rate',
                  '${stats['attendanceRate']}%',
                  AppConfig.primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

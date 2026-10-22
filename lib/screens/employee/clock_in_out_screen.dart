import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/location_provider.dart';
import '../../services/notification_service.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/confirmation_dialog.dart';

class ClockInOutScreen extends StatefulWidget {
  const ClockInOutScreen({super.key});

  @override
  State<ClockInOutScreen> createState() => _ClockInOutScreenState();
}

class _ClockInOutScreenState extends State<ClockInOutScreen> {
  bool _isCheckingLocation = false;

  @override
  void initState() {
    super.initState();
    _checkCurrentStatus();
  }

  Future<void> _checkCurrentStatus() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.checkLocationAndClockIn();
  }

  Future<void> _handleClockIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final employee = authProvider.currentUser!;

    setState(() {
      _isCheckingLocation = true;
    });

    try {
      final success = await attendanceProvider.clockIn(employee, locationProvider);
      
      if (success) {
        await NotificationService.showClockInSuccessNotification(employee.fullName);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully clocked in!'),
              backgroundColor: AppConfig.successColor,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingLocation = false;
        });
      }
    }
  }

  Future<void> _handleClockOut() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final employee = authProvider.currentUser!;

    setState(() {
      _isCheckingLocation = true;
    });

    try {
      final success = await attendanceProvider.clockOut(employee, locationProvider);
      
      if (success) {
        await NotificationService.showClockOutSuccessNotification(employee.fullName);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully clocked out!'),
              backgroundColor: AppConfig.successColor,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingLocation = false;
        });
      }
    }
  }

  Future<void> _showClockOutConfirmation() async {
    final result = await showConfirmationDialog(
      context: context,
      title: 'Confirm Clock Out',
      message: 'Are you sure you want to clock out? Make sure you are at your designated location.',
      confirmText: 'Clock Out',
      cancelText: 'Cancel',
    );
    
    if (result == true) {
      await _handleClockOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    final employee = authProvider.currentUser!;
    final currentRecord = attendanceProvider.currentDayRecord;

    final isClockedIn = currentRecord?.clockInTime != null && 
                       currentRecord?.clockOutTime == null;
    final isClockedOut = currentRecord?.clockOutTime != null;
    final isWithinRadius = locationProvider.isWithinRadius;

    return LoadingOverlay(
      isLoading: attendanceProvider.isLoading || 
                 locationProvider.isLoading || 
                 _isCheckingLocation,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Clock In/Out'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Current date and time
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<DateTime>(
                        stream: Stream.periodic(
                          const Duration(seconds: 1),
                          (i) => DateTime.now(),
                        ),
                        builder: (context, snapshot) {
                          return Text(
                            DateFormat('HH:mm:ss').format(snapshot.data ?? DateTime.now()),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Location Status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Location Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            isWithinRadius ? Icons.check_circle : Icons.error,
                            color: isWithinRadius ? AppConfig.successColor : AppConfig.errorColor,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isWithinRadius 
                                ? 'Within company radius' 
                                : 'Outside company radius',
                            style: TextStyle(
                              fontSize: 16,
                              color: isWithinRadius 
                                  ? AppConfig.successColor 
                                  : AppConfig.errorColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Distance: ${locationProvider.distanceFromCompany.toStringAsFixed(0)} meters',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Clock Status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Today\'s Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      if (isClockedOut)
                        _buildStatusItem(
                          'Status',
                          'Clocked Out',
                          Icons.check_circle,
                          AppConfig.successColor,
                          'You have successfully clocked out for today',
                        )
                      else if (isClockedIn)
                        _buildStatusItem(
                          'Status',
                          'Clocked In',
                          Icons.access_time,
                          AppConfig.primaryColor,
                          'Clock In: ${currentRecord?.clockInTime != null ? DateFormat('HH:mm').format(currentRecord!.clockInTime!) : 'N/A'}',
                        )
                      else
                        _buildStatusItem(
                          'Status',
                          'Not Clocked In',
                          Icons.error,
                          AppConfig.errorColor,
                          'You have not clocked in yet today',
                        ),
                      
                      if (currentRecord != null && currentRecord.clockInTime != null)
                        _buildStatusItem(
                          'Clock In Time',
                          DateFormat('HH:mm').format(currentRecord.clockInTime!),
                          Icons.login,
                          Colors.grey[600],
                          null,
                        ),
                      
                      if (currentRecord != null && currentRecord.clockOutTime != null)
                        _buildStatusItem(
                          'Clock Out Time',
                          DateFormat('HH:mm').format(currentRecord.clockOutTime!),
                          Icons.logout,
                          Colors.grey[600],
                          null,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Working Hours
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Working Hours',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildWorkingHoursItem(
                            'Check-In',
                            employee.checkInTime.format(context),
                          ),
                          _buildWorkingHoursItem(
                            'Check-Out',
                            employee.checkOutTime.format(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Clock Action Button
              if (isClockedOut)
                const Center(
                  child: Text(
                    'You have already clocked out for today',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              else if (isClockedIn)
                ElevatedButton(
                  onPressed: _showClockOutConfirmation,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppConfig.errorColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text(
                        'CLOCK OUT',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                )
              else
                ElevatedButton(
                  onPressed: isWithinRadius ? _handleClockIn : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login),
                      SizedBox(width: 8),
                      Text(
                        'CLOCK IN',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              
              if (!isWithinRadius && !isClockedIn && !isClockedOut)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'You must be within the company radius to clock in',
                    style: TextStyle(
                      color: AppConfig.errorColor,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusItem(
    String title,
    String value,
    IconData icon,
    Color? color,[
    String? subtitle,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title: $value',
                  style: const TextStyle(fontSize: 16),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
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
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/location_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/logo_widget.dart';
import '../../widgets/employee/clock_status_card.dart';
import '../../widgets/employee/attendance_stats_card.dart';
import '../../widgets/employee/location_status_card.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    
    await locationProvider.checkLocationAndClockIn();
    attendanceProvider.clearError();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    final employee = authProvider.currentUser!;

    return LoadingOverlay(
      isLoading: attendanceProvider.isLoading || locationProvider.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshData,
            ),
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () => context.go('/notifications'),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.go('/settings'),
            ),
          ],
        ),
        drawer: _buildDrawer(context, employee),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome message
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${employee.firstName}!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          employee.position,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Employee ID: ${employee.employeeId}',
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
                
                // Today's date
                Text(
                  DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Clock Status Card
                ClockStatusCard(
                  employee: employee,
                  attendanceRecord: attendanceProvider.currentDayRecord,
                ),
                const SizedBox(height: 16),
                
                // Location Status Card
                LocationStatusCard(
                  locationProvider: locationProvider,
                ),
                const SizedBox(height: 16),
                
                // Attendance Stats Card
                AttendanceStatsCard(
                  employeeId: employee.id,
                  attendanceProvider: attendanceProvider,
                ),
                const SizedBox(height: 16),
                
                // Quick Actions
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.go('/employee/clock'),
                        icon: const Icon(Icons.access_time),
                        label: const Text('Clock In/Out'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/employee/attendance'),
                        icon: const Icon(Icons.history),
                        label: const Text('Attendance History'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
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
                        _buildWorkingHoursItem(
                          'Check-In Time',
                          employee.checkInTime.format(context),
                        ),
                        _buildWorkingHoursItem(
                          'Check-Out Time',
                          employee.checkOutTime.format(context),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, Employee employee) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppConfig.primaryColor,
                  AppConfig.secondaryColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                const AppLogo(
                  width: 150,
                  height: 60,
                ),
                const SizedBox(height: 12),
                Text(
                  employee.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  employee.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: true,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Clock In/Out'),
            onTap: () {
              Navigator.pop(context);
              context.go('/employee/clock');
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Attendance History'),
            onTap: () {
              Navigator.pop(context);
              context.go('/employee/attendance');
            },
          ),
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pop(context);
              context.go('/notifications');
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              context.go('/settings');
            },
          ),
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            textColor: AppConfig.errorColor,
            iconColor: AppConfig.errorColor,
            onTap: () async {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}

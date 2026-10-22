import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/employee_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/logo_widget.dart';
import '../../widgets/admin/dashboard_stat_card.dart';
import '../../widgets/admin/today_attendance_list.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    await employeeProvider.initializeWithMockData();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final employeeProvider = Provider.of<EmployeeProvider>(context);
    final admin = authProvider.currentUser!;

    return LoadingOverlay(
      isLoading: employeeProvider.isLoading || attendanceProvider.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
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
        drawer: _buildDrawer(context, admin),
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
                          'Welcome, ${admin.firstName}!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          admin.position,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Admin ID: ${admin.employeeId}',
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
                
                // Statistics Cards
                FutureBuilder(
                  future: employeeProvider.initializeWithMockData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final employees = employeeProvider.employees;
                    final todayAttendance = attendanceProvider.getTodayAttendanceForAllEmployees(employees);
                    
                    int totalEmployees = employees.length;
                    int presentToday = 0;
                    int absentToday = 0;
                    int lateToday = 0;
                    
                    for (final record in todayAttendance.values) {
                      if (record == null) {
                        absentToday++;
                      } else if (record.isFullyPresent) {
                        presentToday++;
                      } else if (record.isLate) {
                        lateToday++;
                      } else {
                        absentToday++;
                      }
                    }

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DashboardStatCard(
                                title: 'Total Employees',
                                value: totalEmployees.toString(),
                                icon: Icons.people,
                                color: AppConfig.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DashboardStatCard(
                                title: 'Present Today',
                                value: presentToday.toString(),
                                icon: Icons.check_circle,
                                color: AppConfig.successColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DashboardStatCard(
                                title: 'Absent Today',
                                value: absentToday.toString(),
                                icon: Icons.error,
                                color: AppConfig.errorColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DashboardStatCard(
                                title: 'Late Today',
                                value: lateToday.toString(),
                                icon: Icons.warning,
                                color: AppConfig.warningColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Today's Attendance
                const Text(
                  "Today's Attendance",
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
                    return TodayAttendanceList(
                      employees: employees,
                      attendanceProvider: attendanceProvider,
                    );
                  },
                ),
                const SizedBox(height: 24),
                
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
                        onPressed: () => context.go('/admin/employees'),
                        icon: const Icon(Icons.people),
                        label: const Text('Manage Employees'),
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
                      child: ElevatedButton.icon(
                        onPressed: () => context.go('/admin/reports'),
                        icon: const Icon(Icons.analytics),
                        label: const Text('View Reports'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppConfig.secondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, Employee admin) {
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
                  admin.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  admin.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Administrator',
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
            leading: const Icon(Icons.people),
            title: const Text('Manage Employees'),
            onTap: () {
              Navigator.pop(context);
              context.go('/admin/employees');
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Reports'),
            onTap: () {
              Navigator.pop(context);
              context.go('/admin/reports');
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

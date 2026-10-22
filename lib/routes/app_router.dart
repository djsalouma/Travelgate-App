import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/employee/employee_dashboard.dart';
import '../screens/employee/clock_in_out_screen.dart';
import '../screens/employee/attendance_history_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/employee_management_screen.dart';
import '../screens/admin/reports_screen.dart';
import '../screens/admin/employee_detail_screen.dart';
import '../screens/admin/report_detail_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/notifications_screen.dart';
import '../config/app_config.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = authProvider.isLoggedIn;
      final userRole = authProvider.userRole;
      
      // Check if trying to access auth screens while logged in
      if (isLoggedIn && (state.location == '/login' || state.location == '/register')) {
        if (userRole == AppConfig.roleAdmin) {
          return '/admin/dashboard';
        } else {
          return '/employee/dashboard';
        }
      }
      
      // Check if trying to access protected routes without login
      if (!isLoggedIn && state.location != '/splash' && 
          state.location != '/login' && 
          state.location != '/register') {
        return '/login';
      }
      
      // Admin-only routes
      if (isLoggedIn && userRole != AppConfig.roleAdmin) {
        if (state.location.startsWith('/admin')) {
          return '/employee/dashboard';
        }
      }
      
      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Authentication Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Employee Routes
      GoRoute(
        path: '/employee/dashboard',
        builder: (context, state) => const EmployeeDashboard(),
      ),
      GoRoute(
        path: '/employee/clock',
        builder: (context, state) => const ClockInOutScreen(),
      ),
      GoRoute(
        path: '/employee/attendance',
        builder: (context, state) => const AttendanceHistoryScreen(),
      ),
      
      // Admin Routes
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/admin/employees',
        builder: (context, state) => const EmployeeManagementScreen(),
      ),
      GoRoute(
        path: '/admin/employees/:employeeId',
        builder: (context, state) {
          final employeeId = state.pathParams['employeeId']!;
          return EmployeeDetailScreen(employeeId: employeeId);
        },
      ),
      GoRoute(
        path: '/admin/reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/admin/reports/:reportType',
        builder: (context, state) {
          final reportType = state.pathParams['reportType']!;
          return ReportDetailScreen(reportType: reportType);
        },
      ),
      
      // Common Routes
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.message ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/employee/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
}

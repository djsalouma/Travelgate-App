import 'package:flutter/material.dart';

import '../config/app_config.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock notifications for demo
    final notifications = [
      NotificationItem(
        id: '1',
        title: 'Clock-In Successful',
        message: 'You have successfully clocked in for today.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isRead: true,
        type: 'clock_in',
      ),
      NotificationItem(
        id: '2',
        title: 'Late Arrival',
        message: 'You were 15 minutes late for work today.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
        type: 'late',
      ),
      NotificationItem(
        id: '3',
        title: 'Check-Out Reminder',
        message: 'Don\'t forget to clock out at the end of your shift!',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        isRead: false,
        type: 'reminder',
      ),
      NotificationItem(
        id: '4',
        title: 'Clock-Out Successful',
        message: 'You have successfully clocked out for today.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        type: 'clock_out',
      ),
      NotificationItem(
        id: '5',
        title: 'Weekly Report Available',
        message: 'Your weekly attendance report is ready to view.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isRead: false,
        type: 'report',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              // Clear all notifications
            },
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationItem(notification, context);
        },
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(notification.timestamp);
    
    String timeAgo;
    if (difference.inMinutes < 1) {
      timeAgo = 'Just now';
    } else if (difference.inHours < 1) {
      timeAgo = '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      timeAgo = '${difference.inHours} hours ago';
    } else {
      timeAgo = '${difference.inDays} days ago';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: _getNotificationColor(notification.type),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: notification.isRead ? Colors.black : AppConfig.primaryColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: TextStyle(
                fontSize: 14,
                color: notification.isRead ? Colors.grey[600] : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              timeAgo,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : Icon(
                Icons.circle,
                size: 12,
                color: AppConfig.primaryColor,
              ),
        onTap: () {
          // Mark as read and navigate if needed
        },
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'clock_in':
        return AppConfig.successColor;
      case 'clock_out':
        return AppConfig.successColor;
      case 'late':
        return AppConfig.warningColor;
      case 'early':
        return AppConfig.infoColor;
      case 'reminder':
        return AppConfig.primaryColor;
      case 'report':
        return AppConfig.secondaryColor;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'clock_in':
        return Icons.login;
      case 'clock_out':
        return Icons.logout;
      case 'late':
        return Icons.warning;
      case 'early':
        return Icons.info;
      case 'reminder':
        return Icons.notifications;
      case 'report':
        return Icons.analytics;
      default:
        return Icons.notifications_none;
    }
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String type;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.type,
  });
}

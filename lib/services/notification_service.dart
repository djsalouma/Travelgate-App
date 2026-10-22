import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../config/app_config.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();

    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS initialization
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
        // Handle notification tap
      },
    );

    // Initialization settings for both platforms
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize notifications
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
        if (response.payload != null) {
          // Navigate to appropriate screen based on payload
        }
      },
    );

    // Create notification channel
    await _createNotificationChannel();

    // Request permission
    await _requestPermission();
  }

  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      AppConfig.notificationChannelId,
      AppConfig.notificationChannelName,
      description: AppConfig.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> _requestPermission() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // Show immediate notification
  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    Map<String, String>? data,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      AppConfig.notificationChannelId,
      AppConfig.notificationChannelName,
      channelDescription: AppConfig.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Schedule notification
  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    Map<String, String>? data,
  }) async {
    final androidNotificationDetails = AndroidNotificationDetails(
      AppConfig.notificationChannelId,
      AppConfig.notificationChannelName,
      channelDescription: AppConfig.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    final iosNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      scheduledTime.millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: 
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // Schedule daily check-in reminder
  static Future<void> scheduleDailyCheckInReminder(TimeOfDay time) async {
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime.add(const Duration(days: 1));
    }

    await scheduleNotification(
      title: 'Check-In Reminder',
      body: 'Don\'t forget to check in for work today!',
      scheduledTime: scheduledTime,
      payload: 'check_in_reminder',
    );
  }

  // Schedule daily check-out reminder
  static Future<void> scheduleDailyCheckOutReminder(TimeOfDay time) async {
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime.add(const Duration(days: 1));
    }

    await scheduleNotification(
      title: 'Check-Out Reminder',
      body: 'Don\'t forget to check out at the end of your shift!',
      scheduledTime: scheduledTime,
      payload: 'check_out_reminder',
    );
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  // Cancel a specific notification
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  // Get pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  // Show notification for successful clock-in
  static Future<void> showClockInSuccessNotification(String employeeName) async {
    await showNotification(
      title: 'Clock-In Successful',
      body: 'Hello $employeeName! You have successfully clocked in for today.',
      payload: 'clock_in_success',
    );
  }

  // Show notification for successful clock-out
  static Future<void> showClockOutSuccessNotification(String employeeName) async {
    await showNotification(
      title: 'Clock-Out Successful',
      body: 'Hello $employeeName! You have successfully clocked out for today.',
      payload: 'clock_out_success',
    );
  }

  // Show notification for late arrival
  static Future<void> showLateArrivalNotification(int minutesLate) async {
    await showNotification(
      title: 'Late Arrival',
      body: 'You are $minutesLate minutes late for work today.',
      payload: 'late_arrival',
    );
  }

  // Show notification for early departure
  static Future<void> showEarlyDepartureNotification(int minutesEarly) async {
    await showNotification(
      title: 'Early Departure',
      body: 'You left $minutesEarly minutes early today.',
      payload: 'early_departure',
    );
  }

  // Show notification when outside radius
  static Future<void> showOutsideRadiusNotification() async {
    await showNotification(
      title: 'Outside Work Area',
      body: 'You are currently outside the designated work area.',
      payload: 'outside_radius',
    );
  }
}

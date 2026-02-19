import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class ReminderService extends GetxService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<ReminderService> init() async {
    // Initialize timezone data
    tz.initializeTimeZones();
    final info = await FlutterTimezone.getLocalTimezone();
    final String timeZoneName = info.identifier;
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
    );

    // Request permissions for Android 13+
    final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    // Schedule the daily reminders if enabled
    final settingsBox = await Hive.openBox('settings_box');
    final bool isEnabled = settingsBox.get('smart_reminders_enabled', defaultValue: true);
    
    if (isEnabled) {
      await scheduleDailyReminders();
    } else {
      await cancelAllReminders();
    }
    
    return this;
  }

  Future<void> scheduleDailyReminders() async {
    // Clear previous before scheduling to avoid duplicates
    await cancelAllReminders();
    // 1. Afternoon Reminder (2:00 PM)
    await _scheduleDaily(
      id: 101,
      title: 'Lunch break? 🍔',
      body: 'Don\'t forget to log your midday expenses! Keeping it fresh helps accuracy.',
      hour: 14,
      minute: 0,
    );

    // 2. Evening Reminder (9:00 PM)
    await _scheduleDaily(
      id: 102,
      title: 'Wrapping up the day? 🌙',
      body: 'Take a moment to record any remaining spends. Stay on top of your goal!',
      hour: 21,
      minute: 0,
    );
  }

  Future<void> _scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: _nextInstanceOfTime(hour, minute),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminders',
            'Daily Reminders',
            channelDescription: 'Scheduled reminders to log expenses',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      print('Error scheduling reminder: $e');
      // Fallback or handle error gracefully
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    print('Scheduling reminder for: $scheduledDate (Local Time: $now)');
    return scheduledDate;
  }

  Future<void> cancelAllReminders() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> showTestNotification() async {
    await _notificationsPlugin.show(
      id: 888,
      title: 'Test Notification 🧪',
      body: 'If you see this, notifications are working correctly!',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Daily Reminders',
          channelDescription: 'Scheduled reminders to log expenses',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> scheduleTestReminderInOneMinute() async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final tz.TZDateTime scheduledDate = now.add(const Duration(minutes: 1));

    print('Scheduling TEST reminder for: $scheduledDate');

    await _notificationsPlugin.zonedSchedule(
      id: 999,
      title: 'Scheduled Test ⏰',
      body: 'This notification was scheduled 1 minute ago!',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Daily Reminders',
          channelDescription: 'Scheduled reminders to log expenses',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}

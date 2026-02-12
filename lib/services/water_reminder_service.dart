import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:ui';

class WaterReminderService {
  static final WaterReminderService _instance =
      WaterReminderService._internal();
  factory WaterReminderService() => _instance;
  WaterReminderService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  NotificationDetails get _waterNotificationDetails {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'that_girl_water',
        'Water Reminders',
        channelDescription: 'Hourly water intake reminders',
        importance: Importance.high,
        priority: Priority.high,
        color: const Color(0xFF06B6D4),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  Future<void> scheduleHourlyReminders() async {
    // Cancel existing water reminders (IDs 2000-2012)
    for (int i = 2000; i <= 2012; i++) {
      await _plugin.cancel(i);
    }

    final now = DateTime.now();
    int notifId = 2000;

    // Schedule for 9 AM - 9 PM every hour
    for (int hour = 9; hour <= 21; hour++) {
      var scheduledTime = DateTime(now.year, now.month, now.day, hour);
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        notifId++,
        'Time to hydrate! \u{1F4A7}',
        'Stay on track with your water goal!',
        tz.TZDateTime.from(scheduledTime, tz.local),
        _waterNotificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> cancelAllReminders() async {
    for (int i = 2000; i <= 2012; i++) {
      await _plugin.cancel(i);
    }
  }
}

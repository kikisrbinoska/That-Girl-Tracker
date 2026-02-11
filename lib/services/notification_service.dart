import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import '../models/event.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }

  NotificationDetails get _notificationDetails {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'that_girl_events',
        'Event Reminders',
        channelDescription: 'Reminders for your scheduled events',
        importance: Importance.high,
        priority: Priority.high,
        color: const Color(0xFFF4A7B9),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  Future<int> scheduleEventNotification(Event event) async {
    final notificationId = event.dateTime.millisecondsSinceEpoch ~/ 1000;
    final scheduledTime = event.dateTime.subtract(const Duration(hours: 1));

    if (scheduledTime.isBefore(DateTime.now())) return notificationId;

    await _plugin.zonedSchedule(
      notificationId,
      'Upcoming: ${event.title}',
      '${Event.typeLabel(event.type)} in 1 hour',
      tz.TZDateTime.from(scheduledTime, tz.local),
      _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    return notificationId;
  }

  Future<void> scheduleDailySummary(List<Event> todayEvents) async {
    final now = DateTime.now();
    var scheduleTime = DateTime(now.year, now.month, now.day, 7);
    if (scheduleTime.isBefore(now)) {
      scheduleTime = scheduleTime.add(const Duration(days: 1));
    }

    final upcoming = todayEvents.take(3).toList();
    final body = upcoming.isEmpty
        ? 'Your day is wide open! ✨'
        : upcoming.map((e) => '${Event.typeLabel(e.type)}: ${e.title}').join(', ');

    await _plugin.zonedSchedule(
      0,
      'Your day ahead, That Girl ✨',
      body,
      tz.TZDateTime.from(scheduleTime, tz.local),
      _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}

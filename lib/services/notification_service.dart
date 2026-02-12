import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import '../models/event.dart';
import 'event_repository.dart';
import 'weather_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  void Function(NotificationResponse)? onNotificationTap;

  Future<void> initialize({
    void Function(NotificationResponse)? onTap,
  }) async {
    if (_initialized) return;

    onNotificationTap = onTap;
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

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse r) {
        if (r.payload == 'morning_outfit' || r.id == 999) {
          onNotificationTap?.call(r);
        }
      },
    );
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

  NotificationDetails get _dailySummaryDetails {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'that_girl_daily_summary',
        'Daily Summary',
        channelDescription: 'Good Morning notification at 7 AM',
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

  /// Schedules daily summary at 7:00 AM. Fetches weather + first event for rich body.
  Future<void> scheduleDailySummaryNotification() async {
    final now = DateTime.now();
    var scheduleTime = DateTime(now.year, now.month, now.day, 7);
    if (scheduleTime.isBefore(now)) {
      scheduleTime = scheduleTime.add(const Duration(days: 1));
    }
    final targetDate = DateTime(scheduleTime.year, scheduleTime.month, scheduleTime.day);

    String body = 'Check your outfit and today\'s schedule! ✨';
    try {
      final weatherService = WeatherService();
      final eventRepo = EventRepository();
      final weather = await weatherService.fetchCurrentWeather();
      final events = await eventRepo.getEventsForDate(targetDate);

      final parts = <String>[];
      parts.add('It\'s ${weather.temperature.round()}°C and ${weather.description} ☀️');
      if (events.isNotEmpty) {
        final first = events.first;
        parts.add('You have ${first.title} at ${_formatTime(first.dateTime)}.');
      }
      parts.add('Check your outfit!');
      body = parts.join(' ');
    } catch (_) {}

    await _plugin.zonedSchedule(
      999,
      'Good Morning, That Girl! ☀️',
      body,
      tz.TZDateTime.from(scheduleTime, tz.local),
      _dailySummaryDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute;
    if (h == 0) return '12:${m.toString().padLeft(2, '0')} AM';
    if (h < 12) return '$h:${m.toString().padLeft(2, '0')} AM';
    if (h == 12) return '12:${m.toString().padLeft(2, '0')} PM';
    return '${h - 12}:${m.toString().padLeft(2, '0')} PM';
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

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
    NotificationService._();
    static final NotificationService _instance = NotificationService._();
    factory NotificationService() => _instance;

    final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

    static const String _channelId = 'reminders_channel';
    static const String _channelName = 'Reminders';
    static const String _channelDesc = 'Daily and weekly reminders';

    Future<void> init() async {
        // Timezone + plugin init
        tz.initializeTimeZones();
        final androidSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
        final initSettings = InitializationSettings(android: androidSettings, iOS: DarwinInitializationSettings());
        await _plugin.initialize(initSettings);

        // Android channel
        const androidChannel = AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.defaultImportance,
        );
        await _plugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(androidChannel);
    }

    // IDs for different reminders
    static const int idDailyWorkout = 1001;
    static const int idDailyCalories = 1002;
    static const int idWeeklySummary = 1003;

    Future<void> cancelAll() => _plugin.cancelAll();

    Future<void> cancel(int id) => _plugin.cancel(id);

    Future<void> showTestNow({
        required String title,
        required String body,
    }) async {
        await _plugin.show(
            DateTime.now().millisecondsSinceEpoch.remainder(100000),
            title,
            body,
            NotificationDetails(
                android: AndroidNotificationDetails(
                    _channelId,
                    _channelName,
                    channelDescription: _channelDesc,
                    importance: Importance.defaultImportance,
                    priority: Priority.defaultPriority,
                ),
                iOS: const DarwinNotificationDetails(),
            ),
        );
    }

    Future<void> scheduleDaily({
        required int id,
        required TimeOfDay time,
        required String title,
        required String body,
    }) async {
        final now = tz.TZDateTime.now(tz.local);
        var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
        if (scheduled.isBefore(now)) {
            scheduled = scheduled.add(const Duration(days: 1));
        }

        await _plugin.zonedSchedule(
            id,
            title,
            body,
            scheduled,
            NotificationDetails(
                android: AndroidNotificationDetails(
                    _channelId,
                    _channelName,
                    channelDescription: _channelDesc,
                    importance: Importance.defaultImportance,
                    priority: Priority.defaultPriority,
                ),
                iOS: const DarwinNotificationDetails(),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time, // daily at this time
        );
    }

    Future<void> scheduleWeekly({
        required int id,
        required int weekday, // 1=Mon ... 7=Sun
        required TimeOfDay time,
        required String title,
        required String body,
    }) async {
        final now = tz.TZDateTime.now(tz.local);

        tz.TZDateTime next = tz.TZDateTime(
            tz.local,
            now.year,
            now.month,
            now.day,
            time.hour,
            time.minute,
        );

        // Move to the requested weekday/time
        while (next.weekday != weekday || !next.isAfter(now)) {
            next = next.add(const Duration(days: 1));
        }

        await _plugin.zonedSchedule(
            id,
            title,
            body,
            next,
            NotificationDetails(
                android: AndroidNotificationDetails(
                    _channelId,
                    _channelName,
                    channelDescription: _channelDesc,
                    importance: Importance.defaultImportance,
                    priority: Priority.defaultPriority,
                ),
                iOS: const DarwinNotificationDetails(),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // weekly
        );
    }
}
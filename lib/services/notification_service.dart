import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance =
      NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const List<String> _transactionReminders = [
    'Your wallet has been suspiciously quiet today.',
    'Psst. What did today actually cost you.',
    'LEDGRR is waiting. Do not leave it hanging.',
    'Today happened. Your balance would like to know how.',
    'Two taps. That is all today is asking for.',
  ];

  static const List<String> _streakReminders = [
    'Your streak is on the line. One tap keeps it alive.',
    'Do not let today be the day the streak breaks.',
    'Your streak is watching. Log something before it goes.',
  ];

  static const Map<int, Map<String, String>> _weeklyNudges = {
    DateTime.tuesday: {
      'title': 'A new lesson is waiting',
      'body': 'Got two minutes. Level up your money brain today.',
      'route': 'learn',
    },
    DateTime.friday: {
      'title': 'Ghost check',
      'body':
          'Haven\'t checked for ghosts lately. Some might be haunting your wallet.',
      'route': 'ghost',
    },
    DateTime.sunday: {
      'title': 'Curious about your money',
      'body': 'Just ask. LEDGRR knows your real numbers.',
      'route': 'ask',
    },
  };

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings =
        InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<void> scheduleDailyReminders({
    required bool loggedToday,
    required int currentStreak,
  }) async {
    if (!_initialized) await initialize();

    await _plugin.cancel(1);
    await _plugin.cancel(2);

    if (loggedToday) return;

    final now = DateTime.now();
    final today = now.weekday;

    final usesStreakMessage = currentStreak > 0;
    final pool =
        usesStreakMessage ? _streakReminders : _transactionReminders;
    final message = pool[today % pool.length];

    var scheduledTime =
        DateTime(now.year, now.month, now.day, 20, 30);
    if (scheduledTime.isBefore(now)) {
      return;
    }

    await _plugin.zonedSchedule(
      1,
      'LEDGRR',
      message,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily reminder',
          channelDescription: 'A daily nudge to log your transactions',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'add_transaction',
    );

    final nudge = _weeklyNudges[today];
    if (nudge != null) {
      var nudgeTime = DateTime(now.year, now.month, now.day, 19, 0);
      if (nudgeTime.isAfter(now)) {
        await _plugin.zonedSchedule(
          2,
          nudge['title']!,
          nudge['body']!,
          tz.TZDateTime.from(nudgeTime, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'feature_nudge',
              'Feature nudges',
              channelDescription:
                  'Occasional nudges toward other LEDGRR features',
              importance: Importance.low,
              priority: Priority.low,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: nudge['route'],
        );
      }
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
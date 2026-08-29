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
    'Somewhere, a transaction is going unlogged. Fix that.',
    'Your True Balance is currently guessing. Help it out.',
    'Even a zero-spend day deserves a log. Tell LEDGRR nothing happened.',
    'Future you will thank present you for two taps right now.',
    'The receipt in your pocket is not going to scan itself.',
    'Quick one — what moved today, in or out?',
    'LEDGRR keeps a diary. Today\'s page is still blank.',
    'Your money did something today. LEDGRR just doesn\'t know what yet.',
  ];

  static const List<String> _streakReminders = [
    'Your streak is on the line. One tap keeps it alive.',
    'Do not let today be the day the streak breaks.',
    'Your streak is watching. Log something before it goes.',
    'You\'ve shown up this many days straight. Don\'t stop now.',
    'One log stands between today and a broken streak.',
    'This streak took real days to build. Don\'t let tonight undo it.',
    'Quietly, persistently, your streak is asking for two taps.',
  ];

  static const Map<int, Map<String, String>> _weeklyNudges = {
    DateTime.tuesday: {
      'title': 'A new lesson is waiting',
      'body': 'Got two minutes. Level up your money brain today.',
      'route': 'learn',
    },
    DateTime.wednesday: {
      'title': 'Any dues piling up?',
      'body': 'Quick check-in on who owes who. Keep it clean.',
      'route': 'dues',
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

  static const List<String> _eventFarOut = [
    '{name} is still a while out — a little saved now beats a scramble later.',
    'No rush, but {name} is on the horizon. Worth a small deposit today.',
    'Early bird move: put something toward {name} while it\'s easy.',
  ];

  static const List<String> _eventMidRange = [
    '{name} is getting closer. Your jar could use a top-up.',
    'Halfway-ish to {name}. How\'s the saving going?',
    '{name} is on its way. A quick deposit now keeps things easy later.',
  ];

  static const List<String> _eventUrgent = [
    '{name} is almost here — {amount} still to go.',
    'Just a few days to {name}. Worth checking your progress.',
    '{name} is close. Your future self will appreciate the head start.',
  ];

  static const List<String> _eventFinal = [
    '{name} is tomorrow or today. Last call to top up.',
    'This is it — {name} is nearly here.',
    '{name}\'s moment has almost arrived. Ready or not.',
  ];

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('ic_stat_notify');
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
    final message = pool[(today + now.day) % pool.length];

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
          sound: RawResourceAndroidNotificationSound('coin_notify'),
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

  Future<void> scheduleEventReminders(
      List<Map<String, dynamic>> events) async {
    if (!_initialized) await initialize();

    for (final event in events) {
      final id = event['id'] as String?;
      if (id == null) continue;

      final notifId = _stableEventNotificationId(id);
      await _plugin.cancel(notifId);

      final date = event['date'] as DateTime?;
      if (date == null) continue;

      final daysLeft = date.difference(DateTime.now()).inDays;
      if (daysLeft < 0) continue;

      final priority = event['priority'] as String? ?? 'Want to happen';
      if (!_isNudgeDay(daysLeft, priority)) continue;

      final name = event['name'] as String? ?? 'Your event';
      final budget = (event['budget'] as num?)?.toDouble() ?? 0;
      final saved = (event['saved'] as num?)?.toDouble() ?? 0;
      final remaining = (budget - saved).clamp(0, double.infinity).toDouble();

      final message = _eventMessage(name, daysLeft, remaining);

      var time = DateTime.now();
      time = DateTime(time.year, time.month, time.day, 18, 30);
      if (time.isBefore(DateTime.now())) continue;

      await _plugin.zonedSchedule(
        notifId,
        'LEDGRR',
        message,
        tz.TZDateTime.from(time, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'event_reminder',
            'Event Wallet reminders',
            channelDescription:
                'Reminders to save toward upcoming events, scaled by urgency and priority',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'event:$id',
      );
    }
  }

  int _stableEventNotificationId(String eventId) =>
      3000 + (eventId.hashCode.abs() % 1000);

  bool _isNudgeDay(int daysLeft, String priority) {
    if (daysLeft <= 2) return true;

    if (daysLeft <= 7) {
      if (priority == 'Maybe') return daysLeft % 3 == 0;
      return daysLeft % 2 == 0;
    }

    if (daysLeft <= 14) {
      if (priority == 'Must happen') return daysLeft % 3 == 0;
      if (priority == 'Maybe') return false;
      return daysLeft % 7 == 0;
    }

    if (priority == 'Must happen') return daysLeft % 7 == 0;
    return false;
  }

  String _eventMessage(String name, int daysLeft, double remaining) {
    List<String> pool;
    if (daysLeft <= 2) {
      pool = _eventFinal;
    } else if (daysLeft <= 7) {
      pool = _eventUrgent;
    } else if (daysLeft <= 14) {
      pool = _eventMidRange;
    } else {
      pool = _eventFarOut;
    }

    final template = pool[(name.length + daysLeft) % pool.length];
    final amountText =
        remaining > 0 ? '₹${remaining.toStringAsFixed(0)}' : 'nothing left';

    return template
        .replaceAll('{name}', name)
        .replaceAll('{amount}', amountText);
  }

  static const int _balanceNotificationId = 999;

  Future<void> showBalanceNotification(double balance) async {
    if (!_initialized) await initialize();

    final formatted = balance >= 100000
        ? '₹${(balance / 100000).toStringAsFixed(1)}L'
        : balance >= 1000
            ? '₹${(balance / 1000).toStringAsFixed(1)}K'
            : '₹${balance.toStringAsFixed(0)}';

    await _plugin.show(
      _balanceNotificationId,
      'LEDGRR',
      'Your True Balance is $formatted right now.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'balance_persistent',
          'True Balance',
          channelDescription:
              'A persistent notification showing your live True Balance',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          showWhen: false,
          sound: RawResourceAndroidNotificationSound('coin_notify'),
        ),
      ),
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
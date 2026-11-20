import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import '../navigation/app_navigator.dart';
import 'dart:convert';
import '../../screens/check_in_screen.dart';
import '../../screens/exercise/calm_grounding_screen.dart';
import '../../screens/insights_screen.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static const int dailyCheckInId = 1001;
  static const int exerciseSuggestionId = 1002;
  static const int weeklyInsightsId = 1003;

  static const String _channelId = 'mindmate_reminders';
  static const String _channelName = 'MindMate Reminders';

  bool _initialized = false;

  Future<bool> _scheduleSafely({
    required int notificationId,
    required String notificationName,
    required Future<void> Function() schedule,
  }) async {
    try {
      final permissionGranted = await areNotificationsEnabled();

      if (!permissionGranted) {
        debugPrint(
          'MindMate: $notificationName was not scheduled. '
              'Notification permission is disabled.',
        );
        return false;
      }

      await schedule();

      debugPrint(
        'MindMate: $notificationName scheduled successfully.',
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'MindMate: Failed to schedule $notificationName '
            '(ID: $notificationId): $e',
      );
      debugPrintStack(stackTrace: stackTrace);

      return false;
    }
  }

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _notifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    final notificationAppLaunchDetails =
    await _notifications.getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      _onNotificationTapped(
        notificationAppLaunchDetails!.notificationResponse!,
      );
    }

    _initialized = true;
  }

  Future<void> _onNotificationTapped(
      NotificationResponse response,
      ) async {
    final payload = response.payload;

    if (payload == null || payload.isEmpty) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;

      Widget? destination;

      switch (data['type']) {
        case 'daily_check_in':
          destination = CheckInScreen(
            onBackToHome: () {
              AppNavigator.navigatorKey.currentState?.popUntil(
                    (route) => route.isFirst,
              );
            },
          );
          break;

        case 'exercise_suggestion':
          destination = const CalmGroundingScreen();
          break;

        case 'weekly_insights':
          destination = InsightsScreen(
            onBackToHome: () {
              AppNavigator.navigatorKey.currentState?.popUntil(
                    (route) => route.isFirst,
              );
            },
          );
          break;
      }

      if (destination == null) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppNavigator.navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => destination!,
          ),
        );
      });
    } catch (e) {
      debugPrint('Could not open notification destination: $e');
    }
  }

  Future<bool> areNotificationsEnabled() async {
    await initialize();

    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final enabled =
    await androidImplementation?.areNotificationsEnabled();

    return enabled ?? false;
  }

  Future<bool> requestPermission() async {
    await initialize();

    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation == null) {
      return false;
    }

    final enabled =
    await androidImplementation.requestNotificationsPermission();

    debugPrint('MindMate notification permission: $enabled');

    return enabled ?? false;
  }

  NotificationDetails get _notificationDetails {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Gentle wellbeing reminders from MindMate.',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> scheduleDailyCheckIn(String preferredTime) async {


    final time = _getPreferredTime(preferredTime);

    await _scheduleSafely(
      notificationId: dailyCheckInId,
      notificationName: 'Daily check-in',
      schedule: () async {
        await _notifications.zonedSchedule(
          id: dailyCheckInId,
          title: 'A moment for yourself',
          body: 'Take a moment to check in with how you are feeling today.',
          payload: jsonEncode({
            'type': 'daily_check_in',
            'title': 'A moment for yourself',
            'message': 'Take a moment to check in with how you are feeling today.',
          }),
          scheduledDate: _nextTime(time.$1, time.$2),
          notificationDetails: _notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      },
    );
  }

  Future<void> scheduleExerciseSuggestion() async {


    await _scheduleSafely(
      notificationId: exerciseSuggestionId,
      notificationName: 'Exercise suggestion',
      schedule: () async {
        await _notifications.zonedSchedule(
          id: exerciseSuggestionId,
          title: 'A little movement can help',
          body: 'Take a short break and try a gentle wellbeing exercise.',
          payload: jsonEncode({
            'type': 'exercise_suggestion',
            'title': 'A little movement can help',
            'message': 'Take a short break and try a gentle wellbeing exercise.',
          }),
          scheduledDate: _nextTime(17, 0),
          notificationDetails: _notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      },
    );
  }

  Future<void> scheduleWeeklyInsights() async {


    await _scheduleSafely(
      notificationId: weeklyInsightsId,
      notificationName: 'Weekly insights',
      schedule: () async {
        await _notifications.zonedSchedule(
          id: weeklyInsightsId,
          title: 'Your weekly wellbeing reflection',
          body: 'Take a moment to reflect on your wellbeing this week.',
          payload: jsonEncode({
            'type': 'weekly_insights',
            'title': 'Your weekly wellbeing reflection',
            'message': 'Take a moment to reflect on your wellbeing this week.',
          }),
          scheduledDate: _nextSundayAtSix(),
          notificationDetails: _notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      },
    );
  }

  // //

  Future<void> cancelDailyCheckIn() async {
    await _notifications.cancel(id: dailyCheckInId);
  }

  Future<void> cancelExerciseSuggestion() async {
    await _notifications.cancel(id: exerciseSuggestionId);
  }

  Future<void> cancelWeeklyInsights() async {
    await _notifications.cancel(id: weeklyInsightsId);
  }

  Future<void> cancelAllReminders() async {
    await _notifications.cancel(id: dailyCheckInId);
    await _notifications.cancel(id: exerciseSuggestionId);
    await _notifications.cancel(id: weeklyInsightsId);
  }

  (int, int) _getPreferredTime(String preferredTime) {
    switch (preferredTime) {
      case 'Morning':
        return (9, 0);
      case 'Afternoon':
        return (14, 0);
      case 'Evening':
        return (19, 0);
      case 'Night':
        return (21, 0);
      default:
        return (19, 0);
    }
  }

  tz.TZDateTime _nextTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  tz.TZDateTime _nextSundayAtSix() {
    final now = tz.TZDateTime.now(tz.local);

    var daysUntilSunday = DateTime.sunday - now.weekday;

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      18,
    ).add(Duration(days: daysUntilSunday));

    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    return scheduledDate;
  }
}

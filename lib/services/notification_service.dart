import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/assignment.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  NotificationService._init();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }


  Future<void> showSavedNotification({
    required String title,
    required String subject,
  }) async {
    await init();
    await _plugin.show(
      0,
      '✅ Assignment Saved!',
      '"$title" ($subject) successfully saved.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'assignment_channel',
          'Assignment Reminders',
          channelDescription: 'Assignment deadline reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }


  Future<void> scheduleForAssignment(Assignment assignment) async {
    await init();
    await cancelForAssignment(assignment.id);

    final now = DateTime.now();
    final deadline = assignment.deadline;


    final threeDaysBefore = DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
      9,
      0,
      0,
    ).subtract(const Duration(days: 3));

    final dayBefore = DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
      21,
      0,
      0,
    ).subtract(const Duration(days: 1));

    final dueDay = DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
      8,
      0,
      0,
    );

    if (threeDaysBefore.isAfter(now)) {
      await _scheduleNotification(
        id: assignment.id * 10 + 2,
        title: '📅 3 Days Left!',
        body:
            '"${assignment.title}" (${assignment.subject}) is due in 3 days. Start working on it!',
        scheduledTime: threeDaysBefore,
      );
    }

  
    if (dayBefore.isAfter(now)) {
      await _scheduleNotification(
        id: assignment.id * 10,
        title: '⚠️ Deadline Tomorrow!',
        body:
            '"${assignment.title}" (${assignment.subject}) is due tomorrow. Don\'t forget to submit!',
        scheduledTime: dayBefore,
      );
    }

    // Due day notification
    if (dueDay.isAfter(now)) {
      await _scheduleNotification(
        id: assignment.id * 10 + 1,
        title: '🔴 Due Today!',
        body:
            '"${assignment.title}" (${assignment.subject}) is due today. Submit before the deadline!',
        scheduledTime: dueDay,
      );
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'assignment_channel',
          'Assignment Reminders',
          channelDescription: 'Assignment deadline reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }


  Future<void> cancelForAssignment(int assignmentId) async {
    await _plugin.cancel(assignmentId * 10);
    await _plugin.cancel(assignmentId * 10 + 1);
    await _plugin.cancel(assignmentId * 10 + 2);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}

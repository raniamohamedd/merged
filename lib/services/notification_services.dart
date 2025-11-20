// NotificationService.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;

class NotificationService {
static final FlutterLocalNotificationsPlugin _notifications =
FlutterLocalNotificationsPlugin();

static Future<void> init() async {
tzData.initializeTimeZones();

const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

final InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);

await _notifications.initialize(initSettings);

}

static Future<void> showTestNotification() async {
await _notifications.show(
0,
'Test Notification',
'This is a test notification',
NotificationDetails(
android: AndroidNotificationDetails(
'med_channel',
'Medication Reminders',
importance: Importance.max,
priority: Priority.high,
),
),
);
}

static Future<void> showScheduledNotification({
required int id,
required String title,
required String body,
required tz.TZDateTime scheduledTime,
}) async {
await _notifications.zonedSchedule(
id,
title,
body,
scheduledTime,
NotificationDetails(
android: AndroidNotificationDetails(
'med_channel',
'Medication Reminders',
importance: Importance.max,
priority: Priority.high,
),
),
androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
matchDateTimeComponents: DateTimeComponents.time, // للتكرار اليومي
);
}

static Future<void> cancelNotification(int id) async {
await _notifications.cancel(id);
}

static Future<void> cancelAllNotifications() async {
await _notifications.cancelAll();
}
}

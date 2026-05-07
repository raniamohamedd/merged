import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/services/dose_confirmation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static GlobalKey<NavigatorState>? navigatorKey;

  static Future<void> init({
    required GlobalKey<NavigatorState> navKey,
  }) async {
    navigatorKey = navKey;

tz_data.initializeTimeZones();
tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;

        try {
          final data = jsonDecode(payload) as Map<String, dynamic>;

          if (data["type"] == "dose_confirmation") {
            navigatorKey?.currentState?.push(
              MaterialPageRoute(
               builder: (_) => DoseConfirmationScreen(
  medicationId: data["medicationId"]?.toString() ?? "",
  medicationName: data["medicationName"]?.toString() ?? "",
  dosage: data["dosage"]?.toString() ?? "",
  scheduledTime: data["scheduledTime"]?.toString() ?? "",
),
              ),
            );
          }
        } catch (_) {}
      },
    );

    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }
static Future<void> showScheduledNotification({
  required int id,
  required String title,
  required String body,
  required tz.TZDateTime scheduledTime,
  String? payload,
}) async {
  await _notifications.zonedSchedule(
    id,
    title,
    body,
    scheduledTime,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'med_channel',
        'Medication Reminders',
        channelDescription: 'Medication reminder notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    payload: payload,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,

    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

    // 🔥 مهم جدًا عشان الإشعار يشتغل في نفس الوقت كل يوم لو تكرر
    matchDateTimeComponents: DateTimeComponents.time,
  );
}
  static Future<void> showWeeklyScheduledNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledTime,
    String? payload,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'med_channel',
          'Medication Reminders',
          channelDescription: 'Medication reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
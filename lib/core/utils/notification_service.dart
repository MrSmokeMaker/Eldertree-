import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/member_model.dart';

part 'notification_service.g.dart';

@Riverpod(keepAlive: true)
NotificationService notificationService(NotificationServiceRef ref) {
  return NotificationService();
}

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<String> _onNotificationTap =
      StreamController<String>.broadcast();
  Stream<String> get onNotificationTap => _onNotificationTap.stream;

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          _onNotificationTap.add(response.payload!);
        }
      },
    );
  }

  Future<void> requestPermissionGently(BuildContext context) async {
    final bool? proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Never miss a memory'),
        content: const Text(
          'Allow notifications so we can gently remind you about birthdays and important family anniversaries.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not now'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Allow'),
          ),
        ],
      ),
    );

    if (proceed != true) return;

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<void> scheduleBirthdayNotification(MemberModel member) async {
    if (member.birthDate == null || member.deathDate != null) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      member.birthDate!.month,
      member.birthDate!.day,
      9,
      0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = tz.TZDateTime(tz.local, now.year + 1,
          member.birthDate!.month, member.birthDate!.day, 9, 0);
    }

    final notificationId = member.id.hashCode;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'family_events',
      'Family Events',
      channelDescription: 'Reminders for birthdays and anniversaries',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      notificationId,
      'Birthday Today! 🎉',
      "It's ${member.firstName}'s birthday. Tap to listen to their voice capsules or record a new memory.",
      scheduledDate,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      payload: member.id,
    );
  }
}

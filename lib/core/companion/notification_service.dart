import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

part 'notification_service.g.dart';

/// One notification ready to be handed to the system.
class ScheduledText {
  const new({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
  });

  final int id;

  /// Local wall-clock time of arrival.
  final DateTime at;
  final String title;
  final String body;
}

/// Local notifications behind an interface (`CLAUDE.md` rule 11) so tests and
/// the planner need no device.
abstract interface class NotificationService {
  /// Prepares the plugin and the time zone. Safe to call twice.
  Future<void> init();

  /// Asks the player for permission (the system dialog). `true` when allowed.
  Future<bool> requestPermission();

  /// Replaces every scheduled notification with [notes].
  Future<void> scheduleAll(List<ScheduledText> notes);

  /// Cancels everything scheduled.
  Future<void> cancelAll();

  /// Whether this launch came from tapping one of our notifications.
  Future<bool> launchedFromNotification();
}

/// The real thing: `flutter_local_notifications` with inexact alarms (no
/// exact-alarm permission needed; a reminder a few minutes late is fine).
class LocalNotificationService implements NotificationService {
  new();

  static const String _channelId = 'chime_companion';
  static const String _channelName = 'Chime Companion';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  @override
  Future<void> init() async {
    if (_ready) return;
    try {
      tzdata.initializeTimeZones();
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } on Object catch (e) {
      // Falls back to UTC; times are then off by the offset but still fire.
      debugPrint('notifications: time zone unavailable ($e)');
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  @override
  Future<bool> requestPermission() async {
    try {
      return await _requestPermission();
    } on Object catch (e) {
      debugPrint('notifications: permission failed ($e)');
      return false;
    }
  }

  Future<bool> _requestPermission() async {
    await init();
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.requestNotificationsPermission() ?? false;
    }
    if (Platform.isIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await ios?.requestPermissions(alert: true, sound: true) ?? false;
    }
    return false;
  }

  @override
  Future<void> scheduleAll(List<ScheduledText> notes) async {
    try {
      await _scheduleAll(notes);
    } on Object catch (e) {
      debugPrint('notifications: scheduling failed ($e)');
    }
  }

  Future<void> _scheduleAll(List<ScheduledText> notes) async {
    await init();
    await _plugin.cancelAll();
    for (final n in notes) {
      await _plugin.zonedSchedule(
        id: n.id,
        title: n.title,
        body: n.body,
        scheduledDate: tz.TZDateTime.from(n.at, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: 'Gentle reminders and good news',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  @override
  Future<void> cancelAll() async {
    try {
      await init();
      await _plugin.cancelAll();
    } on Object catch (e) {
      debugPrint('notifications: cancel failed ($e)');
    }
  }

  @override
  Future<bool> launchedFromNotification() async {
    try {
      await init();
      final details = await _plugin.getNotificationAppLaunchDetails();
      return details?.didNotificationLaunchApp ?? false;
    } on Object {
      return false;
    }
  }
}

/// A scriptable [NotificationService] for tests.
class FakeNotificationService implements NotificationService {
  new({this.permission = true, this.launchedByNote = false});

  /// What the system dialog answers.
  bool permission;

  /// What [launchedFromNotification] returns.
  bool launchedByNote;

  int permissionRequests = 0;
  int cancels = 0;
  List<ScheduledText> scheduled = const [];

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return permission;
  }

  @override
  Future<void> scheduleAll(List<ScheduledText> notes) async =>
      scheduled = notes;

  @override
  Future<void> cancelAll() async {
    cancels++;
    scheduled = const [];
  }

  @override
  Future<bool> launchedFromNotification() async => launchedByNote;
}

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) => LocalNotificationService();

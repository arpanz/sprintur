import 'dart:io';

import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../data/settings.dart';
import '../timer/workout.dart';

/// Local notifications only: nothing goes through a server.
///
/// Tapping one opens the app; [onOpen] gets the payload, which names the
/// tab to show.
class Notifications {
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<bool>? _ready;

  void Function(String payload)? onOpen;

  static const _reminderBase = 100; // + weekday
  static const _nudgeId = 200;
  static const _pbId = 300;

  static const backupNudgeAfter = Duration(days: 30);

  Future<bool> _init() => _ready ??= () async {
    try {
      tzdata.initializeTimeZones();
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (e) {
      debugPrint('Time zone lookup failed, reminders use UTC: $e');
    }
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_notification'),
          // Asked for when the user turns reminders on, not at launch.
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (r) => onOpen?.call(r.payload ?? ''),
      );
      final launch = await _plugin.getNotificationAppLaunchDetails();
      final payload = launch?.notificationResponse?.payload;
      if (launch?.didNotificationLaunchApp == true && payload != null) {
        // Let the first frame build before navigating.
        Future<void>.delayed(
          const Duration(milliseconds: 600),
          () => onOpen?.call(payload),
        );
      }
      return true;
    } catch (e) {
      debugPrint('Notifications unavailable: $e');
      return false;
    }
  }();

  /// Starts the plugin so a tap that launched the app is handled.
  Future<void> start() => _init();

  /// Asks the OS. True when notifications may be shown.
  Future<bool> requestPermission() async {
    if (!await _init()) return false;
    if (Platform.isIOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, sound: true) ??
          false;
    }
    return await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission() ??
        false;
  }

  static NotificationDetails _details(String channel, String name) =>
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel,
          name,
          importance: Importance.defaultImportance,
          color: const Color(0xFFD4FF3A),
        ),
        iOS: const DarwinNotificationDetails(),
      );

  /// One weekly notification per chosen day, replacing any before.
  Future<void> scheduleReminders(AppSettings settings, Workout next) async {
    if (!await _init()) return;
    for (var day = 1; day <= 7; day++) {
      await _plugin.cancel(id: _reminderBase + day);
    }
    final now = tz.TZDateTime.now(tz.local);
    for (final day in settings.reminderDays) {
      var at = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        settings.reminderMinutes ~/ 60,
        settings.reminderMinutes % 60,
      );
      while (at.weekday != day || !at.isAfter(now)) {
        at = at.add(const Duration(days: 1));
      }
      await _plugin.zonedSchedule(
        id: _reminderBase + day,
        scheduledDate: at,
        title: 'Sprint day',
        body: reminderBody(next),
        notificationDetails: _details('reminders', 'Training reminders'),
        // Inexact keeps us clear of the exact-alarm permission; a few
        // minutes late is fine for a reminder.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: 'home',
      );
    }
  }

  /// A single reminder [backupNudgeAfter] past the last backup. Moved each
  /// time a backup happens, so it only fires if they stop.
  Future<void> scheduleBackupNudge(
    DateTime? lastBackupAt,
    DateTime? since,
  ) async {
    if (!await _init()) return;
    await _plugin.cancel(id: _nudgeId);
    final from = lastBackupAt ?? since;
    if (from == null) return;
    final now = tz.TZDateTime.now(tz.local);
    final due = from.toLocal().add(backupNudgeAfter);
    var at = tz.TZDateTime(tz.local, due.year, due.month, due.day, 18);
    // Overdue: tomorrow evening, unless they open the app and back up first.
    if (!at.isAfter(now)) {
      at = tz.TZDateTime(tz.local, now.year, now.month, now.day + 1, 18);
    }
    await _plugin.zonedSchedule(
      id: _nudgeId,
      scheduledDate: at,
      title: 'No backup in 30 days',
      body:
          'Your history only lives on this phone. Export a backup so you '
          'do not lose it.',
      notificationDetails: _details('backups', 'Backups'),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'settings',
    );
  }

  Future<void> showPersonalBest(
    int distanceM,
    double timeS,
    double gain,
  ) async {
    if (!await _init()) return;
    await _plugin.show(
      id: _pbId,
      title: 'New personal best',
      body:
          '$distanceM m in ${timeS.toStringAsFixed(2)} s. That is '
          '${gain.toStringAsFixed(2)} s faster than your previous best.',
      notificationDetails: _details('records', 'New personal bests'),
      payload: 'history',
    );
  }
}

String reminderBody(Workout w) =>
    'Next up: ${w.reps} × ${w.distanceM} m ${w.name.toLowerCase()}. '
    'Grab your cones.';

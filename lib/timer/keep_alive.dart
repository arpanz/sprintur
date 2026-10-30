import 'dart:io';
import 'dart:ui' show Color;

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Keeps a session running with the screen off.
///
/// iOS: an active playback audio session. The beep mixer streams continuously
/// once started, and with the `audio` background mode in Info.plist that keeps
/// the app alive. Android: a foreground service with a partial wake lock and
/// an ongoing notification showing the rep and phase.
class SessionKeepAlive {
  static bool _configured = false;

  /// Call once before the audio engine starts.
  static Future<void> configure() async {
    if (_configured) return;
    _configured = true;
    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        // Beeps play over the runner's music without pausing it.
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.mixWithOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.sonification,
          usage: AndroidAudioUsage.assistanceSonification,
        ),
        androidWillPauseWhenDucked: false,
      ),
    );
    if (Platform.isAndroid) {
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'session',
          channelName: 'Running session',
          channelDescription: 'Shown while a sprint session is running',
          onlyAlertOnce: true,
        ),
        iosNotificationOptions: const IOSNotificationOptions(
          showNotification: false,
        ),
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.nothing(),
          allowWakeLock: true,
          allowAutoRestart: false,
          stopWithTask: true,
        ),
      );
    }
  }

  bool _active = false;
  String? _lastText;

  Future<void> start({required String title, required String text}) async {
    if (_active) return;
    _active = true;
    try {
      await (await AudioSession.instance).setActive(true);
      if (Platform.isAndroid) {
        await FlutterForegroundTask.requestNotificationPermission();
        await FlutterForegroundTask.startService(
          serviceTypes: [ForegroundServiceTypes.mediaPlayback],
          notificationTitle: title,
          notificationText: text,
          notificationIcon: const NotificationIcon(
            metaDataName: 'com.livinlabs.sprintur.NOTIFICATION_ICON',
            backgroundColor: Color(0xFFD4FF3A),
          ),
        );
        _lastText = '$title|$text';
      }
    } catch (e) {
      debugPrint('Could not keep the session alive in the background: $e');
    }
  }

  /// Cheap to call often: only changed text reaches the platform.
  Future<void> update({required String title, required String text}) async {
    final key = '$title|$text';
    if (!_active || !Platform.isAndroid || key == _lastText) return;
    _lastText = key;
    await FlutterForegroundTask.updateService(
      notificationTitle: title,
      notificationText: text,
    );
  }

  Future<void> stop() async {
    if (!_active) return;
    _active = false;
    _lastText = null;
    try {
      if (Platform.isAndroid) await FlutterForegroundTask.stopService();
      await (await AudioSession.instance).setActive(
        false,
        avAudioSessionSetActiveOptions:
            AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
      );
    } catch (e) {
      debugPrint('Stopping background keep-alive failed: $e');
    }
  }
}

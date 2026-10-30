import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'session_engine.dart';
import 'workout.dart';

/// The running session on the iOS lock screen and Dynamic Island
/// (ios/Runner/LiveActivityChannel.swift). The system ticks the clock
/// itself, so this only sends phase changes. Does nothing elsewhere; Android
/// shows the foreground service notification instead.
class SessionLiveActivity {
  static const _channel = MethodChannel('sprintur/live_activity');

  bool _started = false;
  Map<String, Object?>? _last;

  /// Lock screen fields for [s], with the clock's end or start as wall time.
  static Map<String, Object?> stateOf(
    Workout w,
    SessionState s,
    Duration elapsed,
    DateTime wallNow,
  ) {
    int? at(Duration? d) =>
        d == null ? null : wallNow.add(d - elapsed).millisecondsSinceEpoch;
    final last = s.results.lastOrNull?.timeS;
    return {
      'phase': switch (s.phase) {
        Phase.ready || Phase.leadIn => 'GET READY',
        Phase.marks => 'ON YOUR MARKS',
        Phase.set => 'SET',
        Phase.running => 'RUN',
        Phase.rest => 'REST',
        Phase.done => 'DONE',
      },
      'rep': s.rep,
      'reps': w.reps,
      'detail': switch (s.phase) {
        Phase.done => '${s.results.length} reps done',
        Phase.rest when last != null =>
          'Last ${last.toStringAsFixed(2)} s · next ${w.distanceM} m',
        _ => 'Next: ${w.distanceM} m',
      },
      'endsAt': s.phase == Phase.rest || s.phase == Phase.leadIn
          ? at(s.phaseEndsAt)
          : null,
      'startedAt': s.phase == Phase.running ? at(s.runStartedAt) : null,
    };
  }

  Future<void> show(Workout w, Map<String, Object?> state) async {
    if (!Platform.isIOS || mapEquals(state, _last)) return;
    _last = state;
    try {
      if (_started) {
        await _channel.invokeMethod('update', state);
      } else {
        _started = true;
        await _channel.invokeMethod('start', {
          ...state,
          'workout': '${w.reps} × ${w.distanceM} m ${w.name}',
        });
      }
    } catch (e) {
      debugPrint('Live activity failed: $e');
    }
  }

  Future<void> end() async {
    if (!Platform.isIOS || !_started) return;
    _started = false;
    try {
      await _channel.invokeMethod('end');
    } catch (e) {
      debugPrint('Live activity end failed: $e');
    }
  }
}

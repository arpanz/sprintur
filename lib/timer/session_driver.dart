import 'dart:async';

import 'package:flutter/foundation.dart';

import 'session_engine.dart';
import 'workout.dart';

/// Runs a [SessionEngine] against a monotonic [Stopwatch], waking a one-shot
/// timer exactly when the next event is due.
///
/// Listeners are told about phase changes only. Screens that show a running
/// clock read [now] from their own ticker each frame.
class SessionDriver extends ChangeNotifier {
  SessionDriver({
    required Workout workout,
    required void Function(Cue cue) onCue,
  }) {
    engine = SessionEngine(
      workout: workout,
      onCue: onCue,
      onChange: (_) => notifyListeners(),
    );
  }

  late final SessionEngine engine;
  final Stopwatch _clock = Stopwatch()..start();
  Timer? _timer;
  bool _disposed = false;

  Workout get workout => engine.workout;
  SessionState get state => engine.state;
  Duration get now => _clock.elapsed;

  void start() => _act(engine.start);
  void tap() => _act(engine.tap);
  void stop() => _act(engine.stop);

  void _act(void Function(Duration now) action) {
    if (_disposed) return;
    action(now);
    _reschedule();
  }

  void _reschedule() {
    _timer?.cancel();
    final due = engine.nextDeadline;
    if (due == null || _disposed) return;
    final wait = due - now;
    _timer = Timer(wait.isNegative ? Duration.zero : wait, () {
      engine.advance(now);
      _reschedule();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _clock.stop();
    super.dispose();
  }
}

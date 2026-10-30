import 'dart:math';

import 'workout.dart';

/// A sound (and haptic) the session asks the player to make.
enum Cue {
  /// 3-2-1 before the first "marks", and before a restart after a false start.
  countdown,
  marks,
  set,
  go,

  /// The runner should be passing a split cone now.
  split,

  /// Target time reached: the runner should be crossing the line.
  pace,

  /// A partner tapped the finish (tap mode only).
  finish,

  /// 3-2-1 at the end of rest.
  restTick,
  falseStart,
  done,
}

enum Phase { ready, leadIn, marks, set, running, rest, done }

class RepResult {
  const RepResult({required this.rep, this.timeS, this.falseStarts = 0});

  final int rep;

  /// Measured time in seconds. Null in [FinishMode.auto], or when a tap-mode
  /// rep timed out without a tap.
  final double? timeS;

  final int falseStarts;
}

/// Snapshot of a session. Times are offsets on the engine's clock.
class SessionState {
  const SessionState({
    this.phase = Phase.ready,
    this.rep = 1,
    this.phaseStartedAt = Duration.zero,
    this.phaseEndsAt,
    this.runStartedAt,
    this.results = const [],
    this.falseStartsThisRep = 0,
  });

  final Phase phase;

  /// 1-based rep currently being run or prepared.
  final int rep;
  final Duration phaseStartedAt;

  /// When the phase ends on its own, if it has a fixed length (lead-in, rest,
  /// an auto-mode run). Null for phases with a random or open end.
  final Duration? phaseEndsAt;
  final Duration? runStartedAt;
  final List<RepResult> results;
  final int falseStartsThisRep;

  /// Seconds since "go" in the current rep, or 0 outside a run.
  double runElapsedS(Duration now) {
    final start = runStartedAt;
    if (phase != Phase.running || start == null) return 0;
    return _seconds(now - start);
  }

  /// Seconds left in a fixed-length phase, or null.
  double? secondsLeft(Duration now) {
    final end = phaseEndsAt;
    if (end == null) return null;
    return max(0, _seconds(end - now));
  }

  SessionState copyWith({
    Phase? phase,
    int? rep,
    Duration? phaseStartedAt,
    Duration? Function()? phaseEndsAt,
    Duration? Function()? runStartedAt,
    List<RepResult>? results,
    int? falseStartsThisRep,
  }) {
    return SessionState(
      phase: phase ?? this.phase,
      rep: rep ?? this.rep,
      phaseStartedAt: phaseStartedAt ?? this.phaseStartedAt,
      phaseEndsAt: phaseEndsAt != null ? phaseEndsAt() : this.phaseEndsAt,
      runStartedAt: runStartedAt != null ? runStartedAt() : this.runStartedAt,
      results: results ?? this.results,
      falseStartsThisRep: falseStartsThisRep ?? this.falseStartsThisRep,
    );
  }
}

double _seconds(Duration d) =>
    d.inMicroseconds / Duration.microsecondsPerSecond;

Duration _duration(double seconds) =>
    Duration(microseconds: (seconds * Duration.microsecondsPerSecond).round());

enum _Kind {
  countdown,
  toMarks,
  toSet,
  toGo,
  split,
  pace,
  endRun,
  restTick,
  endRest,
}

class _Event {
  const _Event(this.at, this.kind);
  final Duration at;
  final _Kind kind;
}

/// The sprint session state machine.
///
/// It owns no clock and no timers: the caller passes the current time into
/// [start], [tap] and [advance], and reads [nextDeadline] to know when to call
/// [advance] again. Every transition uses the time its event was scheduled
/// for, not the time [advance] ran, so a late timer never shifts the beeps
/// that follow it.
class SessionEngine {
  SessionEngine({
    required this.workout,
    required this.onCue,
    this.onChange,
    Duration Function()? pickHold,
    this.leadIn = const Duration(seconds: 5),
    this.falseStartLeadIn = const Duration(seconds: 3),
    this.marksToSet = const Duration(seconds: 2),
  }) : _pickHold = pickHold ?? _randomHold;

  final Workout workout;
  final void Function(Cue cue) onCue;
  final void Function(SessionState state)? onChange;

  /// Time to walk to the line after pressing start.
  final Duration leadIn;
  final Duration falseStartLeadIn;
  final Duration marksToSet;
  final Duration Function() _pickHold;

  /// A tap-mode rep with no tap ends after this many times the target.
  static const tapTimeoutFactor = 3.0;

  static final _rng = Random();
  static Duration _randomHold() => _duration(1.5 + _rng.nextDouble() * 1.5);

  SessionState _state = const SessionState();
  SessionState get state => _state;

  final List<_Event> _queue = [];

  Duration? get nextDeadline => _queue.isEmpty ? null : _queue.first.at;

  void start(Duration now) {
    if (_state.phase != Phase.ready) return;
    _enterLeadIn(now, leadIn);
  }

  /// The one big button: a false start before go, the finish in tap mode, and
  /// skipping the rest of a rest.
  void tap(Duration now) {
    advance(now);
    switch (_state.phase) {
      case Phase.marks:
      case Phase.set:
        onCue(Cue.falseStart);
        _set(
          _state.copyWith(falseStartsThisRep: _state.falseStartsThisRep + 1),
        );
        _enterLeadIn(now, falseStartLeadIn);
      case Phase.running:
        if (workout.finishMode == FinishMode.tap) {
          onCue(Cue.finish);
          _endRun(now, timeS: _state.runElapsedS(now));
        }
      case Phase.rest:
        _enterMarks(now);
      case Phase.ready:
      case Phase.leadIn:
      case Phase.done:
        break;
    }
  }

  /// Ends the session early. Reps already run stay in the results.
  void stop(Duration now) {
    if (_state.phase == Phase.done) return;
    _queue.clear();
    _set(
      _state.copyWith(
        phase: Phase.done,
        phaseStartedAt: now,
        phaseEndsAt: () => null,
        runStartedAt: () => null,
      ),
    );
  }

  /// Fires every event due at or before [now], in order.
  void advance(Duration now) {
    while (_queue.isNotEmpty && _queue.first.at <= now) {
      _handle(_queue.removeAt(0));
    }
  }

  void _handle(_Event e) {
    switch (e.kind) {
      case _Kind.countdown:
        onCue(Cue.countdown);
      case _Kind.toMarks:
        _enterMarks(e.at);
      case _Kind.toSet:
        onCue(Cue.set);
        _queue.clear();
        _set(_state.copyWith(phase: Phase.set, phaseStartedAt: e.at));
        _schedule(e.at + _pickHold(), _Kind.toGo);
      case _Kind.toGo:
        _enterRun(e.at);
      case _Kind.split:
        onCue(Cue.split);
      case _Kind.pace:
        onCue(Cue.pace);
      case _Kind.endRun:
        _endRun(e.at, timeS: null);
      case _Kind.restTick:
        onCue(Cue.restTick);
      case _Kind.endRest:
        _enterMarks(e.at);
    }
  }

  void _enterLeadIn(Duration at, Duration length) {
    _queue.clear();
    final end = at + length;
    _set(
      _state.copyWith(
        phase: Phase.leadIn,
        phaseStartedAt: at,
        phaseEndsAt: () => end,
        runStartedAt: () => null,
      ),
    );
    _scheduleCountdown(end, _Kind.countdown);
    _schedule(end, _Kind.toMarks);
  }

  /// Without a start signal "marks" is skipped and the rep goes straight away.
  void _enterMarks(Duration at) {
    _queue.clear();
    if (!workout.startSignal) {
      _enterRun(at);
      return;
    }
    onCue(Cue.marks);
    _set(
      _state.copyWith(
        phase: Phase.marks,
        phaseStartedAt: at,
        phaseEndsAt: () => null,
        runStartedAt: () => null,
      ),
    );
    _schedule(at + marksToSet, _Kind.toSet);
  }

  void _enterRun(Duration at) {
    _queue.clear();
    onCue(Cue.go);
    final auto = workout.finishMode == FinishMode.auto;
    final target = _duration(workout.targetS);
    _set(
      _state.copyWith(
        phase: Phase.running,
        phaseStartedAt: at,
        phaseEndsAt: () => auto ? at + target : null,
        runStartedAt: () => at,
      ),
    );
    for (final d in workout.splitDistances) {
      _schedule(at + _duration(workout.targetTimeAt(d)), _Kind.split);
    }
    _schedule(at + target, _Kind.pace);
    _schedule(
      auto ? at + target : at + _duration(workout.targetS * tapTimeoutFactor),
      _Kind.endRun,
    );
  }

  void _endRun(Duration at, {required double? timeS}) {
    _queue.clear();
    final results = [
      ..._state.results,
      RepResult(
        rep: _state.rep,
        timeS: timeS,
        falseStarts: _state.falseStartsThisRep,
      ),
    ];
    if (_state.rep >= workout.reps) {
      onCue(Cue.done);
      _set(
        _state.copyWith(
          phase: Phase.done,
          phaseStartedAt: at,
          phaseEndsAt: () => null,
          runStartedAt: () => null,
          results: results,
          falseStartsThisRep: 0,
        ),
      );
      return;
    }
    final end = at + Duration(seconds: workout.restS);
    _set(
      _state.copyWith(
        phase: Phase.rest,
        rep: _state.rep + 1,
        phaseStartedAt: at,
        phaseEndsAt: () => end,
        runStartedAt: () => null,
        results: results,
        falseStartsThisRep: 0,
      ),
    );
    _scheduleCountdown(end, _Kind.restTick);
    _schedule(end, _Kind.endRest);
  }

  /// Ticks 3, 2 and 1 seconds before [end], skipping any already past.
  void _scheduleCountdown(Duration end, _Kind kind) {
    final from = _state.phaseStartedAt;
    for (var s = 3; s >= 1; s--) {
      final at = end - Duration(seconds: s);
      if (at > from) _schedule(at, kind);
    }
  }

  void _schedule(Duration at, _Kind kind) {
    final event = _Event(at, kind);
    // Stable insert: events at the same time keep the order they were added.
    final i = _queue.indexWhere((e) => e.at > at);
    if (i == -1) {
      _queue.add(event);
    } else {
      _queue.insert(i, event);
    }
  }

  void _set(SessionState next) {
    _state = next;
    onChange?.call(next);
  }
}

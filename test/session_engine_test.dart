import 'package:flutter_test/flutter_test.dart';
import 'package:sprintur/timer/session_engine.dart';
import 'package:sprintur/timer/workout.dart';

Duration ms(int v) => Duration(milliseconds: v);

class Harness {
  Harness(Workout workout, {Duration hold = const Duration(seconds: 2)}) {
    engine = SessionEngine(
      workout: workout,
      onCue: (c) => cues.add((at, c)),
      pickHold: () => hold,
    );
  }

  late final SessionEngine engine;
  final List<(Duration, Cue)> cues = [];
  Duration at = Duration.zero;

  /// Steps through every deadline up to [until], like the driver's timer.
  void runTo(Duration until) {
    while (true) {
      final due = engine.nextDeadline;
      if (due == null || due > until) break;
      at = due;
      engine.advance(due);
    }
    at = until;
  }

  List<Cue> get kinds => [for (final c in cues) c.$2];
}

const _w = Workout(
  name: 'Test',
  reps: 2,
  distanceM: 30,
  targetS: 4.5,
  restS: 10,
);

void main() {
  test('split distances skip start and finish', () {
    expect(_w.splitDistances, [10, 20]);
    expect(_w.copyWith(distanceM: 25).splitDistances, [10, 20]);
    expect(_w.copyWith(splitEveryM: 0).splitDistances, isEmpty);
  });

  test('auto mode runs the full timeline at exact times', () {
    final h = Harness(_w);
    h.engine.start(Duration.zero);
    h.runTo(const Duration(seconds: 60));

    // Lead-in 5 s with 3-2-1, marks at 5, set at 7, go at 9 (2 s hold),
    // splits at 9 + 1.5 and 9 + 3.0, pace at 13.5, then 10 s rest.
    final rep1 = [
      (ms(2000), Cue.countdown),
      (ms(3000), Cue.countdown),
      (ms(4000), Cue.countdown),
      (ms(5000), Cue.marks),
      (ms(7000), Cue.set),
      (ms(9000), Cue.go),
      (ms(10500), Cue.split),
      (ms(12000), Cue.split),
      (ms(13500), Cue.pace),
      (ms(20500), Cue.restTick),
      (ms(21500), Cue.restTick),
      (ms(22500), Cue.restTick),
      (ms(23500), Cue.marks),
    ];
    expect(h.cues.take(rep1.length).toList(), rep1);
    expect(h.kinds.last, Cue.done);
    expect(h.cues.last.$1, ms(23500 + 2000 + 2000 + 4500));

    final s = h.engine.state;
    expect(s.phase, Phase.done);
    expect(s.results.map((r) => r.rep), [1, 2]);
    expect(s.results.every((r) => r.timeS == null), isTrue);
    expect(h.engine.nextDeadline, isNull);
  });

  test('a late advance fires the backlog in order with no drift', () {
    final h = Harness(_w);
    h.engine.start(Duration.zero);
    h.engine.advance(ms(12500));
    expect(h.kinds, [
      Cue.countdown,
      Cue.countdown,
      Cue.countdown,
      Cue.marks,
      Cue.set,
      Cue.go,
      Cue.split,
      Cue.split,
    ]);
    expect(h.engine.state.runStartedAt, ms(9000));
    expect(h.engine.nextDeadline, ms(13500));
  });

  test('tap mode records the tapped time', () {
    final h = Harness(_w.copyWith(finishMode: FinishMode.tap));
    h.engine.start(Duration.zero);
    h.runTo(ms(13600)); // pace beep at 13.5 does not end the rep
    expect(h.engine.state.phase, Phase.running);
    h.engine.tap(ms(13720));
    final r = h.engine.state.results.single;
    expect(r.timeS, closeTo(4.72, 1e-9));
    expect(h.engine.state.phase, Phase.rest);
    expect(h.engine.state.rep, 2);
    expect(h.kinds.last, Cue.finish);
  });

  test('tap mode times out without a tap', () {
    final h = Harness(_w.copyWith(finishMode: FinishMode.tap));
    h.engine.start(Duration.zero);
    h.runTo(ms(9000 + 13499));
    expect(h.engine.state.phase, Phase.running);
    h.runTo(ms(9000 + 13500));
    expect(h.engine.state.phase, Phase.rest);
    expect(h.engine.state.results.single.timeS, isNull);
  });

  test('false start during set restarts the rep after a short lead-in', () {
    final h = Harness(_w);
    h.engine.start(Duration.zero);
    h.runTo(ms(8000));
    expect(h.engine.state.phase, Phase.set);
    h.engine.tap(ms(8000));
    expect(h.kinds.last, Cue.falseStart);
    expect(h.engine.state.phase, Phase.leadIn);
    expect(h.engine.state.rep, 1);
    h.runTo(ms(11000));
    expect(h.engine.state.phase, Phase.marks);
    h.runTo(ms(16000));
    expect(h.engine.state.phase, Phase.running);
    expect(h.engine.state.runStartedAt, ms(15000));
    h.runTo(ms(19500));
    expect(h.engine.state.results.single.falseStarts, 1);
  });

  test('tapping in auto run does nothing; tapping in rest skips it', () {
    final h = Harness(_w);
    h.engine.start(Duration.zero);
    h.runTo(ms(10000));
    h.engine.tap(ms(10000));
    expect(h.engine.state.phase, Phase.running);
    h.runTo(ms(15000));
    expect(h.engine.state.phase, Phase.rest);
    h.engine.tap(ms(15000));
    expect(h.engine.state.phase, Phase.marks);
    expect(h.engine.state.rep, 2);
  });

  test('without a start signal each rep goes straight away', () {
    final h = Harness(_w.copyWith(startSignal: false, splitEveryM: 0));
    h.engine.start(Duration.zero);
    h.runTo(const Duration(seconds: 60));
    expect(h.kinds, [
      Cue.countdown,
      Cue.countdown,
      Cue.countdown,
      Cue.go,
      Cue.pace,
      Cue.restTick,
      Cue.restTick,
      Cue.restTick,
      Cue.go,
      Cue.pace,
      Cue.done,
    ]);
  });

  test('stop ends the session and keeps finished reps', () {
    final h = Harness(_w);
    h.engine.start(Duration.zero);
    h.runTo(ms(15000));
    h.engine.stop(ms(15000));
    expect(h.engine.state.phase, Phase.done);
    expect(h.engine.state.results.length, 1);
    expect(h.engine.nextDeadline, isNull);
  });
}

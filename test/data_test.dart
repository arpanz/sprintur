import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprintur/data/database.dart';
import 'package:sprintur/data/stats.dart';
import 'package:sprintur/timer/session_engine.dart';
import 'package:sprintur/timer/session_summary.dart';
import 'package:sprintur/timer/workout.dart';

const _w = Workout(
  name: 'Acceleration',
  reps: 3,
  distanceM: 30,
  targetS: 4.6,
  restS: 120,
  finishMode: FinishMode.tap,
);

SessionSummary _summary(
  List<double?> times,
  DateTime at, {
  Workout workout = _w,
}) => SessionSummary(
  workout: workout,
  results: [
    for (final (i, t) in times.indexed)
      RepResult(rep: i + 1, timeS: t, falseStarts: i == 0 ? 1 : 0),
  ],
  finishedAt: at,
);

StoredSession _stored(String id, List<double?> times, DateTime at) =>
    StoredSession(id: id, summary: _summary(times, at));

void main() {
  group('database', () {
    late AppDatabase db;
    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('saves a session with its reps and reads it back', () async {
      final at = DateTime(2026, 10, 30, 18, 5);
      final id = await db.saveSession(_summary([4.62, null, 4.41], at));
      await db.setRpe(id, 8);

      final sessions = await db.watchSessions().first;
      final s = sessions.single;
      expect(s.id, id);
      expect(s.rpe, 8);
      expect(s.summary.workout, _w);
      expect(s.summary.finishedAt, at);
      expect(s.summary.results.map((r) => r.timeS), [4.62, null, 4.41]);
      expect(s.summary.falseStarts, 1);
    });

    test('lists newest first and deleting removes the reps too', () async {
      final older = await db.saveSession(
        _summary([4.7], DateTime(2026, 10, 20)),
      );
      await db.saveSession(_summary([4.5], DateTime(2026, 10, 29)));

      var sessions = await db.watchSessions().first;
      expect(sessions.map((s) => s.summary.best), [4.5, 4.7]);

      await db.deleteSession(older);
      sessions = await db.watchSessions().first;
      expect(sessions.length, 1);
      final orphanReps = await db.select(db.reps).get();
      expect(orphanReps.length, 1);
    });

    test('saved workouts round-trip', () async {
      await db.saveWorkout(_w.copyWith(name: 'Mine'));
      final saved = await db.watchWorkouts().first;
      expect(saved.single.$2, _w.copyWith(name: 'Mine'));
      await db.deleteWorkout(saved.single.$1);
      expect(await db.watchWorkouts().first, isEmpty);
    });

    test('ids are unique v4 UUIDs', () {
      final ids = {for (var i = 0; i < 200; i++) newId()};
      expect(ids.length, 200);
      expect(
        ids.first,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
    });
  });

  group('stats', () {
    final thu = DateTime(2026, 10, 29, 18);

    test('week starts on Monday and sums metres per day', () {
      expect(weekStart(thu), DateTime(2026, 10, 26));
      final days = weekMetres([
        _stored('a', [4.6, 4.5], DateTime(2026, 10, 26, 7)),
        _stored('b', [4.6], DateTime(2026, 10, 29, 9)),
        _stored('c', [4.6], DateTime(2026, 10, 29, 19)),
        _stored('old', [4.6], DateTime(2026, 10, 25, 23)),
      ], thu);
      expect(days, [60, 0, 0, 60, 0, 0, 0]);
    });

    test('personal bests are per distance and ignore untimed sessions', () {
      final bests = personalBests([
        _stored('a', [4.6, 4.41], DateTime(2026, 10, 1)),
        _stored('b', [4.5], DateTime(2026, 10, 2)),
        _stored('c', [null], DateTime(2026, 10, 3)),
        StoredSession(
          id: 'd',
          summary: _summary(
            [7.62],
            DateTime(2026, 10, 4),
            workout: _w.copyWith(distanceM: 60),
          ),
        ),
      ]);
      expect(bests.map((b) => (b.distanceM, b.timeS)), [
        (30, 4.41),
        (60, 7.62),
      ]);
      expect(bests.first.at, DateTime(2026, 10, 1));
    });

    test('a PB is a session that beats an earlier best', () {
      final ids = pbSessionIds([
        _stored('newest', [4.40], DateTime(2026, 10, 5)),
        _stored('slower', [4.6], DateTime(2026, 10, 3)),
        _stored('first', [4.5], DateTime(2026, 10, 1)),
        _stored('better', [4.45], DateTime(2026, 10, 4)),
      ]);
      expect(ids, {'better', 'newest'});
    });
  });
}

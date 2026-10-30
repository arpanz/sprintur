import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../timer/session_engine.dart';
import '../timer/session_summary.dart';
import '../timer/workout.dart';

part 'database.g.dart';

/// Rows use random UUIDs rather than auto-increment ids so a backup restored
/// on another phone can be merged by id without collisions.
String newId() {
  final rng = Random.secure();
  final b = List<int>.generate(16, (_) => rng.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  final hex = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

/// Workout columns shared by saved workouts and the snapshot kept on each
/// session (so editing a saved workout never rewrites history).
mixin WorkoutColumns on Table {
  TextColumn get name => text()();
  IntColumn get reps => integer()();
  IntColumn get distanceM => integer()();
  RealColumn get targetS => real()();
  IntColumn get restS => integer()();
  IntColumn get splitEveryM => integer()();
  BoolColumn get startSignal => boolean()();
  TextColumn get finishMode => textEnum<FinishMode>()();
}

class SavedWorkouts extends Table with WorkoutColumns {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Sessions extends Table with WorkoutColumns {
  TextColumn get id => text()();
  DateTimeColumn get finishedAt => dateTime()();

  /// Effort from 1 to 10, set on the summary screen.
  IntColumn get rpe => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Reps extends Table {
  TextColumn get sessionId =>
      text().references(Sessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get rep => integer()();
  RealColumn get timeS => real().nullable()();
  IntColumn get falseStarts => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {sessionId, rep};
}

/// A finished session as stored, with its reps.
class StoredSession {
  const StoredSession({required this.id, required this.summary, this.rpe});

  final String id;
  final SessionSummary summary;
  final int? rpe;
}

@DriftDatabase(tables: [SavedWorkouts, Sessions, Reps])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'sprintur'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  // Sessions

  Future<String> saveSession(SessionSummary summary) {
    final id = newId();
    final w = summary.workout;
    return transaction(() async {
      await into(sessions).insert(
        SessionsCompanion.insert(
          id: id,
          finishedAt: summary.finishedAt,
          name: w.name,
          reps: w.reps,
          distanceM: w.distanceM,
          targetS: w.targetS,
          restS: w.restS,
          splitEveryM: w.splitEveryM,
          startSignal: w.startSignal,
          finishMode: w.finishMode,
        ),
      );
      await batch((b) {
        b.insertAll(reps, [
          for (final r in summary.results)
            RepsCompanion.insert(
              sessionId: id,
              rep: r.rep,
              timeS: Value(r.timeS),
              falseStarts: Value(r.falseStarts),
            ),
        ]);
      });
      return id;
    });
  }

  Future<void> setRpe(String sessionId, int? rpe) =>
      (update(sessions)..where((s) => s.id.equals(sessionId))).write(
        SessionsCompanion(rpe: Value(rpe)),
      );

  Future<void> deleteSession(String sessionId) =>
      (delete(sessions)..where((s) => s.id.equals(sessionId))).go();

  /// Every session, newest first, with its reps.
  Stream<List<StoredSession>> watchSessions() {
    final query =
        select(sessions).join([
          leftOuterJoin(reps, reps.sessionId.equalsExp(sessions.id)),
        ])..orderBy([
          OrderingTerm.desc(sessions.finishedAt),
          OrderingTerm.asc(reps.rep),
        ]);

    return query.watch().map((rows) {
      final order = <String>[];
      final heads = <String, Session>{};
      final repsBy = <String, List<RepResult>>{};
      for (final row in rows) {
        final s = row.readTable(sessions);
        if (!heads.containsKey(s.id)) {
          order.add(s.id);
          heads[s.id] = s;
          repsBy[s.id] = [];
        }
        final r = row.readTableOrNull(reps);
        if (r != null) {
          repsBy[s.id]!.add(
            RepResult(rep: r.rep, timeS: r.timeS, falseStarts: r.falseStarts),
          );
        }
      }
      return [
        for (final id in order)
          StoredSession(
            id: id,
            rpe: heads[id]!.rpe,
            summary: SessionSummary(
              workout: _workoutOf(heads[id]!),
              results: repsBy[id]!,
              finishedAt: heads[id]!.finishedAt,
            ),
          ),
      ];
    });
  }

  // Saved workouts

  Future<void> saveWorkout(Workout w) => into(savedWorkouts).insert(
    SavedWorkoutsCompanion.insert(
      id: newId(),
      createdAt: DateTime.now(),
      name: w.name,
      reps: w.reps,
      distanceM: w.distanceM,
      targetS: w.targetS,
      restS: w.restS,
      splitEveryM: w.splitEveryM,
      startSignal: w.startSignal,
      finishMode: w.finishMode,
    ),
  );

  Future<void> deleteWorkout(String id) =>
      (delete(savedWorkouts)..where((w) => w.id.equals(id))).go();

  Stream<List<(String, Workout)>> watchWorkouts() =>
      (select(savedWorkouts)..orderBy([(w) => OrderingTerm.asc(w.createdAt)]))
          .watch()
          .map((rows) => [for (final r in rows) (r.id, _workoutOf(r))]);

  static Workout _workoutOf(Insertable<dynamic> row) => switch (row) {
    SavedWorkout r => Workout(
      name: r.name,
      reps: r.reps,
      distanceM: r.distanceM,
      targetS: r.targetS,
      restS: r.restS,
      splitEveryM: r.splitEveryM,
      startSignal: r.startSignal,
      finishMode: r.finishMode,
    ),
    Session r => Workout(
      name: r.name,
      reps: r.reps,
      distanceM: r.distanceM,
      targetS: r.targetS,
      restS: r.restS,
      splitEveryM: r.splitEveryM,
      startSignal: r.startSignal,
      finishMode: r.finishMode,
    ),
    _ => throw ArgumentError.value(row, 'row', 'not a workout row'),
  };
}

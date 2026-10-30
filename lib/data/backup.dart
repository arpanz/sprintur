import 'dart:convert';

import 'package:drift/drift.dart';

import '../timer/workout.dart';
import 'database.dart';
import 'settings.dart';

const backupFormat = 'sprintur-backup';
const backupSchemaVersion = 1;

class BackupException implements Exception {
  const BackupException(this.message);
  final String message;

  @override
  String toString() => message;
}

class RestoreResult {
  const RestoreResult({
    required this.sessionsAdded,
    required this.workoutsAdded,
  });

  final int sessionsAdded;
  final int workoutsAdded;
}

/// `sprintur-backup-2026-10-31.json`
String backupFileName(DateTime at) =>
    'sprintur-backup-${at.year}-${_two(at.month)}-${_two(at.day)}.json';

String _two(int n) => n.toString().padLeft(2, '0');

Map<String, Object?> _workoutJson(Insertable<dynamic> row) {
  final w = switch (row) {
    SavedWorkout r => (
      r.name,
      r.reps,
      r.distanceM,
      r.targetS,
      r.restS,
      r.splitEveryM,
      r.startSignal,
      r.finishMode,
    ),
    Session r => (
      r.name,
      r.reps,
      r.distanceM,
      r.targetS,
      r.restS,
      r.splitEveryM,
      r.startSignal,
      r.finishMode,
    ),
    _ => throw ArgumentError.value(row),
  };
  return {
    'name': w.$1,
    'reps': w.$2,
    'distanceM': w.$3,
    'targetS': w.$4,
    'restS': w.$5,
    'splitEveryM': w.$6,
    'startSignal': w.$7,
    'finishMode': w.$8.name,
  };
}

Workout _workoutFrom(Map<String, Object?> j) => Workout(
  name: j['name']! as String,
  reps: (j['reps']! as num).toInt(),
  distanceM: (j['distanceM']! as num).toInt(),
  targetS: (j['targetS']! as num).toDouble(),
  restS: (j['restS']! as num).toInt(),
  splitEveryM: (j['splitEveryM']! as num).toInt(),
  startSignal: j['startSignal']! as bool,
  finishMode: FinishMode.values.byName(j['finishMode']! as String),
);

extension Backup on AppDatabase {
  /// Everything worth keeping, as pretty-printed JSON.
  Future<String> exportJson({DateTime? now}) async {
    final workoutRows = await (select(
      savedWorkouts,
    )..orderBy([(w) => OrderingTerm.asc(w.createdAt)])).get();
    final sessionRows = await (select(
      sessions,
    )..orderBy([(s) => OrderingTerm.asc(s.finishedAt)])).get();
    final repRows = await (select(
      reps,
    )..orderBy([(r) => OrderingTerm.asc(r.rep)])).get();
    final prefsMap = await readPrefs();

    final repsBy = <String, List<Rep>>{};
    for (final r in repRows) {
      (repsBy[r.sessionId] ??= []).add(r);
    }

    final doc = {
      'format': backupFormat,
      'schemaVersion': backupSchemaVersion,
      'exportedAt': (now ?? DateTime.now()).toUtc().toIso8601String(),
      'settings': {
        for (final k in AppSettings.portableKeys)
          if (prefsMap[k] != null) k: prefsMap[k],
      },
      'workouts': [
        for (final w in workoutRows)
          {
            'id': w.id,
            'createdAt': w.createdAt.toUtc().toIso8601String(),
            ..._workoutJson(w),
          },
      ],
      'sessions': [
        for (final s in sessionRows)
          {
            'id': s.id,
            'finishedAt': s.finishedAt.toUtc().toIso8601String(),
            'rpe': s.rpe,
            'workout': _workoutJson(s),
            'reps': [
              for (final r in repsBy[s.id] ?? const <Rep>[])
                {'rep': r.rep, 'timeS': r.timeS, 'falseStarts': r.falseStarts},
            ],
          },
      ],
    };
    return const JsonEncoder.withIndent('  ').convert(doc);
  }

  /// Adds whatever the backup has that this phone does not, matched by id.
  /// Nothing already here is changed or deleted, so restoring twice, or
  /// restoring an older file, is harmless.
  Future<RestoreResult> restoreJson(String text) async {
    final Map<String, Object?> doc;
    try {
      doc = jsonDecode(text) as Map<String, Object?>;
    } catch (_) {
      throw const BackupException('This file is not a Sprintur backup.');
    }
    if (doc['format'] != backupFormat) {
      throw const BackupException('This file is not a Sprintur backup.');
    }
    final version = (doc['schemaVersion'] as num?)?.toInt() ?? 0;
    if (version > backupSchemaVersion) {
      throw const BackupException(
        'This backup was made by a newer version of Sprintur. '
        'Update the app, then try again.',
      );
    }

    try {
      return await transaction(() async {
        var sessionsAdded = 0;
        var workoutsAdded = 0;
        final savedIds = {
          for (final w in await select(savedWorkouts).get()) w.id,
        };

        for (final j
            in (doc['workouts'] as List? ?? const [])
                .cast<Map<String, Object?>>()) {
          final id = j['id']! as String;
          if (savedIds.contains(id)) continue;
          final w = _workoutFrom(j);
          await into(savedWorkouts).insert(
            SavedWorkoutsCompanion.insert(
              id: id,
              createdAt: DateTime.parse(j['createdAt']! as String).toLocal(),
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
          workoutsAdded++;
        }

        final existing = {for (final s in await select(sessions).get()) s.id};
        for (final j
            in (doc['sessions'] as List? ?? const [])
                .cast<Map<String, Object?>>()) {
          final id = j['id']! as String;
          if (existing.contains(id)) continue;
          final w = _workoutFrom(j['workout']! as Map<String, Object?>);
          await into(sessions).insert(
            SessionsCompanion.insert(
              id: id,
              finishedAt: DateTime.parse(j['finishedAt']! as String).toLocal(),
              rpe: Value((j['rpe'] as num?)?.toInt()),
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
          for (final r
              in (j['reps'] as List? ?? const [])
                  .cast<Map<String, Object?>>()) {
            await into(reps).insert(
              RepsCompanion.insert(
                sessionId: id,
                rep: (r['rep']! as num).toInt(),
                timeS: Value((r['timeS'] as num?)?.toDouble()),
                falseStarts: Value((r['falseStarts'] as num?)?.toInt() ?? 0),
              ),
            );
          }
          sessionsAdded++;
        }

        // Only fill in settings this phone has not set itself.
        final current = await readPrefs();
        final settings = (doc['settings'] as Map?)?.cast<String, Object?>();
        for (final k in AppSettings.portableKeys) {
          final v = settings?[k];
          if (v is String && !current.containsKey(k)) await setPref(k, v);
        }

        return RestoreResult(
          sessionsAdded: sessionsAdded,
          workoutsAdded: workoutsAdded,
        );
      });
    } on BackupException {
      rethrow;
    } catch (_) {
      throw const BackupException(
        'This backup is damaged and could not be restored. '
        'Nothing was changed.',
      );
    }
  }

  /// One row per rep, for spreadsheets.
  Future<String> exportCsv() async {
    final stored = await watchSessions().first;
    final out = StringBuffer(
      'date,time,workout,distance_m,target_s,rep,time_s,false_starts,rpe\n',
    );
    for (final s in stored.reversed) {
      final sum = s.summary;
      final at = sum.finishedAt;
      final date = '${at.year}-${_two(at.month)}-${_two(at.day)}';
      final clock = '${_two(at.hour)}:${_two(at.minute)}';
      for (final r in sum.results) {
        out.writeln(
          [
            date,
            clock,
            _csv(sum.workout.name),
            sum.workout.distanceM,
            sum.workout.targetS.toStringAsFixed(2),
            r.rep,
            r.timeS?.toStringAsFixed(2) ?? '',
            r.falseStarts,
            s.rpe ?? '',
          ].join(','),
        );
      }
    }
    return out.toString();
  }
}

String _csv(String v) =>
    v.contains(RegExp('[",\n]')) ? '"${v.replaceAll('"', '""')}"' : v;

import 'dart:convert';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprintur/data/backup.dart';
import 'package:sprintur/data/database.dart';
import 'package:sprintur/data/settings.dart';
import 'package:sprintur/timer/session_engine.dart';
import 'package:sprintur/timer/session_summary.dart';
import 'package:sprintur/timer/workout.dart';

const _w = Workout(
  name: 'Hills, short',
  reps: 3,
  distanceM: 30,
  targetS: 4.6,
  restS: 120,
  finishMode: FinishMode.tap,
);

AppDatabase _db() => AppDatabase(NativeDatabase.memory());

Future<void> _seed(AppDatabase db) async {
  final id = await db.saveSession(
    SessionSummary(
      workout: _w,
      results: const [
        RepResult(rep: 1, timeS: 4.62, falseStarts: 1),
        RepResult(rep: 2),
        RepResult(rep: 3, timeS: 4.41),
      ],
      finishedAt: DateTime(2026, 10, 30, 18, 5),
    ),
  );
  await db.setRpe(id, 8);
  await db.saveWorkout(_w);
  await db.setPref(AppSettings.keyBeepStyle, 'whistle');
  await db.setPref(AppSettings.keyOnboarded, 'true');
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('a backup restores into an empty phone exactly', () async {
    final a = _db();
    final b = _db();
    addTearDown(a.close);
    addTearDown(b.close);
    await _seed(a);

    final json = await a.exportJson(now: DateTime.utc(2026, 10, 31));
    final doc = jsonDecode(json) as Map<String, Object?>;
    expect(doc['format'], 'sprintur-backup');
    expect(doc['schemaVersion'], 1);
    expect((doc['settings']! as Map).containsKey('onboarded'), isFalse);

    final result = await b.restoreJson(json);
    expect(result.sessionsAdded, 1);
    expect(result.workoutsAdded, 1);

    final original = (await a.watchSessions().first).single;
    final restored = (await b.watchSessions().first).single;
    expect(restored.id, original.id);
    expect(restored.rpe, 8);
    expect(restored.summary.workout, _w);
    expect(restored.summary.finishedAt, original.summary.finishedAt);
    expect(restored.summary.results.map((r) => r.timeS), [4.62, null, 4.41]);
    expect(restored.summary.falseStarts, 1);
    expect((await b.watchWorkouts().first).single.$2, _w);

    final prefs = await b.readPrefs();
    expect(prefs[AppSettings.keyBeepStyle], 'whistle');
    expect(prefs.containsKey(AppSettings.keyOnboarded), isFalse);
  });

  test('restoring twice adds nothing and keeps local edits', () async {
    final db = _db();
    addTearDown(db.close);
    await _seed(db);
    final json = await db.exportJson();

    final id = (await db.watchSessions().first).single.id;
    await db.setRpe(id, 3);
    await db.setPref(AppSettings.keyBeepStyle, 'low');

    final result = await db.restoreJson(json);
    expect(result.sessionsAdded, 0);
    expect(result.workoutsAdded, 0);
    final s = (await db.watchSessions().first).single;
    expect(s.rpe, 3);
    expect(s.summary.results.length, 3);
    expect((await db.readPrefs())[AppSettings.keyBeepStyle], 'low');
  });

  test('rejects files that are not backups, newer, or damaged', () async {
    final db = _db();
    addTearDown(db.close);

    await expectLater(
      db.restoreJson('not json'),
      throwsA(isA<BackupException>()),
    );
    await expectLater(
      db.restoreJson('{"format":"something-else"}'),
      throwsA(isA<BackupException>()),
    );
    await expectLater(
      db.restoreJson('{"format":"sprintur-backup","schemaVersion":99}'),
      throwsA(
        isA<BackupException>().having(
          (e) => e.message,
          'message',
          contains('newer version'),
        ),
      ),
    );

    // A good session followed by a broken one: the transaction rolls back.
    const damaged =
        '{"format":"sprintur-backup","schemaVersion":1,"sessions":['
        '{"id":"a","finishedAt":"2026-10-30T18:00:00Z","workout":'
        '{"name":"x","reps":1,"distanceM":30,"targetS":4.6,"restS":60,'
        '"splitEveryM":10,"startSignal":true,"finishMode":"auto"},'
        '"reps":[{"rep":1,"timeS":null}]},'
        '{"id":"b","finishedAt":"not a date"}]}';
    await expectLater(db.restoreJson(damaged), throwsA(isA<BackupException>()));
    expect(await db.watchSessions().first, isEmpty);
  });

  test('CSV has one row per rep and quotes awkward names', () async {
    final db = _db();
    addTearDown(db.close);
    await _seed(db);
    final lines = const LineSplitter().convert(await db.exportCsv());
    expect(
      lines.first,
      'date,time,workout,distance_m,target_s,rep,time_s,false_starts,rpe',
    );
    expect(lines.skip(1), [
      '2026-10-30,18:05,"Hills, short",30,4.60,1,4.62,1,8',
      '2026-10-30,18:05,"Hills, short",30,4.60,2,,0,8',
      '2026-10-30,18:05,"Hills, short",30,4.60,3,4.41,0,8',
    ]);
  });

  test('backup file names use the local date', () {
    expect(
      backupFileName(DateTime(2026, 3, 7)),
      'sprintur-backup-2026-03-07.json',
    );
  });
}

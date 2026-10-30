import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprintur/data/auto_backup.dart';
import 'package:sprintur/data/database.dart';
import 'package:sprintur/data/settings.dart';
import 'package:sprintur/timer/workout.dart';

void main() {
  late AppDatabase db;
  late Directory docs;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    docs = await Directory.systemTemp.createTemp('sprintur-test');
  });
  tearDown(() async {
    await db.close();
    await docs.delete(recursive: true);
  });

  List<String> files() =>
      backupsDir(docs).listSync().map((f) => f.uri.pathSegments.last).toList()
        ..sort();

  test('skips an empty phone, then backs up weekly', () async {
    final day = DateTime(2026, 10, 1, 9);
    expect(await runAutoBackup(db, docs, now: day), isNull);

    await db.saveWorkout(Workout.presets.first);
    expect(await runAutoBackup(db, docs, now: day), isNotNull);
    expect(files(), ['sprintur-backup-2026-10-01.json']);
    final last = AppSettings.fromPrefs(await db.readPrefs()).lastBackupAt;
    expect(last, day.toUtc());

    // Six days later is too soon; seven is due.
    final soon = day.add(const Duration(days: 6));
    expect(await runAutoBackup(db, docs, now: soon), isNull);
    final due = day.add(const Duration(days: 7));
    expect(await runAutoBackup(db, docs, now: due), isNotNull);
    expect(files().length, 2);
  });

  test('keeps only the newest five and respects the switch', () async {
    await db.saveWorkout(Workout.presets.first);
    for (var week = 0; week < 7; week++) {
      final at = DateTime(2026, 1, 1).add(Duration(days: 7 * week));
      await runAutoBackup(db, docs, now: at);
    }
    expect(files(), [
      'sprintur-backup-2026-01-15.json',
      'sprintur-backup-2026-01-22.json',
      'sprintur-backup-2026-01-29.json',
      'sprintur-backup-2026-02-05.json',
      'sprintur-backup-2026-02-12.json',
    ]);

    await db.setPref(AppSettings.keyAutoBackup, 'false');
    expect(await runAutoBackup(db, docs, now: DateTime(2026, 6, 1)), isNull);
  });
}

import 'dart:io';

import 'backup.dart';
import 'database.dart';
import 'settings.dart';

const autoBackupEvery = Duration(days: 7);
const autoBackupsKept = 5;

/// The folder auto backups go in, under the app's documents. On iOS it shows
/// in the Files app as On My iPhone › Sprintur › backups.
Directory backupsDir(Directory documents) =>
    Directory('${documents.path}${Platform.pathSeparator}backups');

/// Writes a backup to [documents]/backups when auto backup is on and the last
/// one is a week old, then keeps only the newest few. Returns the file it
/// wrote, or null when none was due.
Future<File?> runAutoBackup(
  AppDatabase db,
  Directory documents, {
  DateTime? now,
}) async {
  now ??= DateTime.now();
  final settings = AppSettings.fromPrefs(await db.readPrefs());
  if (!settings.autoBackup) return null;
  final last = settings.lastBackupAt;
  if (last != null && now.difference(last) < autoBackupEvery) return null;
  // Nothing worth a file yet.
  if ((await db.watchSessions().first).isEmpty &&
      (await db.watchWorkouts().first).isEmpty) {
    return null;
  }

  final dir = backupsDir(documents);
  await dir.create(recursive: true);
  final file = File(
    '${dir.path}${Platform.pathSeparator}${backupFileName(now)}',
  );
  await file.writeAsString(await db.exportJson(now: now), flush: true);
  await db.setPref(AppSettings.keyLastBackupAt, now.toUtc().toIso8601String());

  // Names sort by date, so the oldest come first.
  final old =
      (await dir.list().toList())
          .whereType<File>()
          .where((f) => f.uri.pathSegments.last.startsWith('sprintur-backup-'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  for (final f in old.reversed.skip(autoBackupsKept)) {
    await f.delete();
  }
  return file;
}

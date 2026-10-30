import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/database.dart';
import '../data/settings.dart';

/// Where releases are published. The update check is the only network call
/// the app makes, and Settings can turn it off.
const releaseRepo = 'arpanz/sprintur';

const updateCheckEvery = Duration(days: 1);

class Release {
  const Release({
    required this.version,
    required this.notes,
    required this.url,
  });

  /// `1.4.0`, without the tag's leading v.
  final String version;

  /// Bullet lines from the release description, at most six.
  final List<String> notes;

  /// The GitHub release page, which links the APK.
  final String url;

  factory Release.fromGitHub(Map<String, Object?> j) => Release(
    version: (j['tag_name']! as String).replaceFirst(RegExp('^v'), ''),
    notes: releaseNotes(j['body'] as String? ?? ''),
    url: j['html_url']! as String,
  );
}

/// Markdown list items, or plain lines when there are none.
List<String> releaseNotes(String body) {
  final lines = const LineSplitter()
      .convert(body)
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty && !l.startsWith('#'))
      .toList();
  final bullets = [
    for (final l in lines)
      if (RegExp(r'^[-*+]\s+').hasMatch(l))
        l.replaceFirst(RegExp(r'^[-*+]\s+'), ''),
  ];
  return (bullets.isNotEmpty ? bullets : lines).take(6).toList();
}

/// True when [candidate] is a later x.y.z than [installed]. Anything after
/// a `-` or `+` is ignored, and missing parts count as 0.
bool isNewer(String candidate, String installed) {
  List<int> parts(String v) => [
    for (final p in v.split(RegExp('[-+]')).first.split('.'))
      int.tryParse(p) ?? 0,
  ];
  final a = parts(candidate);
  final b = parts(installed);
  for (var i = 0; i < 3; i++) {
    final x = i < a.length ? a[i] : 0;
    final y = i < b.length ? b[i] : 0;
    if (x != y) return x > y;
  }
  return false;
}

/// Asks GitHub for the latest release at most once a day. Returns it when it
/// is newer than [installed] and the user has not already said "Later" to
/// it; otherwise null. Network trouble is quietly ignored until tomorrow.
Future<Release?> checkForUpdate(
  AppDatabase db, {
  required String installed,
  http.Client? client,
  DateTime? now,
}) async {
  now ??= DateTime.now();
  final settings = AppSettings.fromPrefs(await db.readPrefs());
  if (!settings.checkUpdates) return null;
  final last = settings.lastUpdateCheck;
  if (last != null && now.difference(last) < updateCheckEvery) return null;

  final c = client ?? http.Client();
  try {
    final res = await c
        .get(
          Uri.https('api.github.com', '/repos/$releaseRepo/releases/latest'),
          headers: {'Accept': 'application/vnd.github+json'},
        )
        .timeout(const Duration(seconds: 10));
    await db.setPref(
      AppSettings.keyLastUpdateCheck,
      now.toUtc().toIso8601String(),
    );
    if (res.statusCode != 200) return null;
    final release = Release.fromGitHub(
      jsonDecode(res.body) as Map<String, Object?>,
    );
    if (!isNewer(release.version, installed)) return null;
    if (release.version == settings.skippedVersion) return null;
    return release;
  } catch (_) {
    return null;
  } finally {
    if (client == null) c.close();
  }
}

import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sprintur/app/updates.dart';
import 'package:sprintur/data/database.dart';
import 'package:sprintur/data/settings.dart';

void main() {
  test('compares versions part by part', () {
    expect(isNewer('1.4.0', '1.3.9'), isTrue);
    expect(isNewer('1.10.0', '1.9.0'), isTrue);
    expect(isNewer('2', '1.9.9'), isTrue);
    expect(isNewer('1.3.2', '1.3.2'), isFalse);
    expect(isNewer('1.3.2-beta', '1.3.2'), isFalse);
    expect(isNewer('1.3.1', '1.3.2'), isFalse);
  });

  test('release notes prefer bullet lines and skip headings', () {
    expect(
      releaseNotes('## Changes\r\n- Faster start\n* Ladder mode\n\nThanks!'),
      ['Faster start', 'Ladder mode'],
    );
    expect(releaseNotes('Bug fixes.\n'), ['Bug fixes.']);
  });

  group('checkForUpdate', () {
    late AppDatabase db;
    var calls = 0;
    final client = MockClient((req) async {
      calls++;
      expect(req.url.path, '/repos/$releaseRepo/releases/latest');
      return http.Response(
        jsonEncode({
          'tag_name': 'v1.4.0',
          'body': '- Voice cues',
          'html_url': 'https://github.com/$releaseRepo/releases/tag/v1.4.0',
        }),
        200,
      );
    });

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      calls = 0;
    });
    tearDown(() => db.close());

    test('finds a newer release once a day', () async {
      final now = DateTime(2026, 10, 31, 9);
      final r = await checkForUpdate(
        db,
        installed: '1.0.0',
        client: client,
        now: now,
      );
      expect(r?.version, '1.4.0');
      expect(r?.notes, ['Voice cues']);

      final again = await checkForUpdate(
        db,
        installed: '1.0.0',
        client: client,
        now: now.add(const Duration(hours: 5)),
      );
      expect(again, isNull);
      expect(calls, 1);
    });

    test('stays quiet when current, skipped, or switched off', () async {
      final now = DateTime(2026, 10, 31);
      expect(
        await checkForUpdate(db, installed: '1.4.0', client: client, now: now),
        isNull,
      );

      await db.setPref(AppSettings.keyLastUpdateCheck, null);
      await db.setPref(AppSettings.keySkippedVersion, '1.4.0');
      expect(
        await checkForUpdate(db, installed: '1.0.0', client: client, now: now),
        isNull,
      );

      await db.setPref(AppSettings.keyLastUpdateCheck, null);
      await db.setPref(AppSettings.keyCheckUpdates, 'false');
      expect(
        await checkForUpdate(db, installed: '1.0.0', client: client, now: now),
        isNull,
      );
      expect(calls, 2);
    });
  });
}

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprintur/app/notifications.dart';
import 'package:sprintur/app/providers.dart';
import 'package:sprintur/app/theme.dart';
import 'package:sprintur/audio/cue_player.dart';
import 'package:sprintur/data/database.dart';
import 'package:sprintur/data/settings.dart';
import 'package:sprintur/main.dart';
import 'package:sprintur/screens/summary_screen.dart';
import 'package:sprintur/timer/session_engine.dart';
import 'package:sprintur/timer/session_summary.dart';
import 'package:sprintur/timer/workout.dart';
import 'package:sprintur/widgets/common.dart';

class _SilentCuePlayer extends CuePlayer {
  final previews = <BeepStyle>[];

  @override
  void play(Cue cue) {}

  @override
  Future<void> preview(BeepStyle preview) async => previews.add(preview);
}

late _SilentCuePlayer _player;

class _SilentNotifications extends Notifications {
  final personalBests = <(int, double)>[];

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> showPersonalBest(
    int distanceM,
    double timeS,
    double gain,
  ) async => personalBests.add((distanceM, timeS));
}

late AppDatabase _db;

Widget _scope(Widget child) => ProviderScope(
  overrides: [
    cuePlayerProvider.overrideWithValue(_player),
    databaseProvider.overrideWithValue(_db),
    notificationsProvider.overrideWithValue(_SilentNotifications()),
  ],
  child: child,
);

Widget _app() => _scope(const SprinturApp(launchTasks: false));

Future<void> _phone(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Unmounts the tree so drift's stream queries are cancelled before the
/// database closes.
Future<void> _finish(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
}

/// Lets drift finish writes started by a tap and deliver the stream updates.
Future<void> _settleDb(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

SessionSummary _summary(List<double?> times, {DateTime? at}) => SessionSummary(
  workout: Workout.presets.first,
  results: [
    for (final (i, t) in times.indexed) RepResult(rep: i + 1, timeS: t),
  ],
  finishedAt: at ?? DateTime(2026, 10, 30, 18, 5),
);

void main() {
  setUp(() async {
    _player = _SilentCuePlayer();
    _db = AppDatabase(NativeDatabase.memory());
    await _db.setPref(AppSettings.keyOnboarded, 'true');
  });
  tearDown(() => _db.close());

  testWidgets('home shows the next workout and switches presets', (
    tester,
  ) async {
    await _phone(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('READY TO FLY?'), findsOneWidget);
    expect(find.textContaining('6 × 30 m'), findsWidgets);

    await tester.ensureVisible(find.text('Tempo 100s'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tempo 100s'));
    await tester.pumpAndSettle();
    expect(find.textContaining('8 × 100 m\nTEMPO 100S'), findsOneWidget);
    expect(find.text('No split beeps'), findsNothing);
    expect(find.text('Beep every 25 m'), findsOneWidget);
    await _finish(tester);
  });

  testWidgets('builder steppers update the workout', (tester) async {
    await _phone(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Build your own'));
    await tester.pumpAndSettle();
    expect(find.text('6 reps · 180 m total'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Increase Reps'));
    await tester.pumpAndSettle();
    expect(find.text('7 reps · 210 m total'), findsOneWidget);

    await tester.ensureVisible(find.text('Off'));
    await tester.tap(find.text('Off'));
    await tester.pumpAndSettle();
    expect(
      find.text('Only the start and the target time beep.'),
      findsOneWidget,
    );
    await _finish(tester);
  });

  Widget summaryOf(List<double?> times) => _scope(
    MaterialApp(
      theme: buildTheme(),
      home: SummaryScreen(summary: _summary(times)),
    ),
  );

  testWidgets('summary shows best and average, saves, and takes effort', (
    tester,
  ) async {
    await _phone(tester);
    await tester.pumpWidget(summaryOf([4.62, 4.48, 4.41]));
    await _settleDb(tester);
    expect(find.text('4.41'), findsWidgets);
    expect(find.text('4.50'), findsOneWidget);
    expect(find.text('2/3'), findsOneWidget);

    await tester.ensureVisible(find.bySemanticsLabel('Effort 8 of 10'));
    await tester.tap(find.bySemanticsLabel('Effort 8 of 10'));
    await tester.pumpAndSettle();

    final saved = (await tester.runAsync(() => _db.watchSessions().first))!;
    expect(saved.single.summary.best, 4.41);
    expect(saved.single.rpe, 8);
    await _finish(tester);
  });

  testWidgets('a faster session shows the new best', (tester) async {
    await tester.runAsync(
      () => _db.saveSession(_summary([4.6], at: DateTime(2026, 10, 1))),
    );
    await _phone(tester);
    await tester.pumpWidget(summaryOf([4.62, 4.41]));
    await _settleDb(tester);
    expect(find.text('NEW 30 M BEST'), findsOneWidget);
    expect(find.text('4.41 s · −0.19'), findsOneWidget);
    await _finish(tester);
  });

  testWidgets('summary explains missing times in auto mode', (tester) async {
    await _phone(tester);
    await tester.pumpWidget(summaryOf([null, null]));
    await _settleDb(tester);
    expect(find.textContaining('partner taps the finish'), findsOneWidget);
    expect(find.text('60'), findsOneWidget);
    await _finish(tester);
  });

  testWidgets('saved sessions show in History and the week on Home', (
    tester,
  ) async {
    await tester.runAsync(
      () => _db.saveSession(_summary([4.62, 4.41], at: DateTime.now())),
    );
    await _phone(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('THIS WEEK'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('60 m'), findsOneWidget);

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('HISTORY'), findsOneWidget);
    expect(find.text('THIS WEEK'), findsOneWidget);
    expect(find.text('Acceleration 2 × 30 m'), findsOneWidget);

    await tester.tap(find.text('Records'));
    await tester.pumpAndSettle();
    expect(find.text('30 m'), findsOneWidget);
    expect(find.text('4.41'), findsOneWidget);
    await _finish(tester);
  });

  testWidgets('builder saves a named workout to Quick start', (tester) async {
    await _phone(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Build your own'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Hill sprints');
    await tester.tap(find.widgetWithText(TextButton, 'Save').last);
    await tester.pumpAndSettle();

    final workouts = (await tester.runAsync(() => _db.watchWorkouts().first))!;
    expect(workouts.single.$2.name, 'Hill sprints');
    await _finish(tester);
  });

  testWidgets('first run picks a beep sound, then shows the app', (
    tester,
  ) async {
    await tester.runAsync(() => _db.setPref(AppSettings.keyOnboarded, null));
    await _phone(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('RUN THE\nCLOCK.'), findsOneWidget);
    expect(find.text('READY TO FLY?'), findsNothing);

    await tester.tap(find.text('Whistle'));
    await tester.pumpAndSettle();
    expect(_player.previews, [BeepStyle.whistle]);

    await tester.tap(find.text('Get started'));
    await _settleDb(tester);
    expect(find.text('READY TO FLY?'), findsOneWidget);
    final prefs = await tester.runAsync(_db.readPrefs);
    expect(prefs![AppSettings.keyBeepStyle], 'whistle');
    await _finish(tester);
  });

  testWidgets('settings shows backup status and saves choices', (tester) async {
    await _phone(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.text('Never'), findsOneWidget);
    expect(find.text('Export'), findsOneWidget);

    await tester.tap(find.text('Low'));
    await tester.tap(find.byType(SprintSwitch));
    await _settleDb(tester);
    final prefs = await tester.runAsync(_db.readPrefs);
    expect(prefs![AppSettings.keyBeepStyle], 'low');
    expect(prefs[AppSettings.keyAutoBackup], 'false');
    expect(_player.previews, [BeepStyle.low]);
    await _finish(tester);
  });
}

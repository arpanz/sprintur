import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprintur/app/providers.dart';
import 'package:sprintur/app/theme.dart';
import 'package:sprintur/audio/cue_player.dart';
import 'package:sprintur/main.dart';
import 'package:sprintur/screens/summary_screen.dart';
import 'package:sprintur/timer/session_engine.dart';
import 'package:sprintur/timer/session_summary.dart';
import 'package:sprintur/timer/workout.dart';

class _SilentCuePlayer extends CuePlayer {
  @override
  void play(Cue cue) {}
}

Widget _app() => ProviderScope(
  overrides: [cuePlayerProvider.overrideWithValue(_SilentCuePlayer())],
  child: const SprinturApp(),
);

Future<void> _phone(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

void main() {
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
  });

  Widget summaryOf(List<double?> times) => MaterialApp(
    theme: buildTheme(),
    home: SummaryScreen(
      summary: SessionSummary(
        workout: Workout.presets.first,
        results: [
          for (final (i, t) in times.indexed) RepResult(rep: i + 1, timeS: t),
        ],
        finishedAt: DateTime(2026, 10, 30, 18, 5),
      ),
    ),
  );

  testWidgets('summary shows best and average for timed reps', (tester) async {
    await _phone(tester);
    await tester.pumpWidget(summaryOf([4.62, 4.48, 4.41]));
    await tester.pumpAndSettle();
    expect(find.text('4.41'), findsWidgets);
    expect(find.text('4.50'), findsOneWidget);
    expect(find.text('2/3'), findsOneWidget);
  });

  testWidgets('summary explains missing times in auto mode', (tester) async {
    await _phone(tester);
    await tester.pumpWidget(summaryOf([null, null]));
    await tester.pumpAndSettle();
    expect(find.textContaining('partner taps the finish'), findsOneWidget);
    expect(find.text('60'), findsOneWidget);
  });
}

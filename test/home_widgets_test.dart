import 'package:flutter_test/flutter_test.dart';
import 'package:sprintur/app/home_widgets.dart';
import 'package:sprintur/data/database.dart';
import 'package:sprintur/data/settings.dart';
import 'package:sprintur/timer/session_engine.dart';
import 'package:sprintur/timer/session_summary.dart';
import 'package:sprintur/timer/workout.dart';

StoredSession _s(String id, List<double?> times, DateTime at, {int d = 30}) =>
    StoredSession(
      id: id,
      summary: SessionSummary(
        workout: Workout.presets.first.copyWith(distanceM: d),
        results: [
          for (final (i, t) in times.indexed) RepResult(rep: i + 1, timeS: t),
        ],
        finishedAt: at,
      ),
    );

void main() {
  final next = Workout.presets.first; // 6 × 30 m Acceleration
  final thu = DateTime(2026, 10, 29, 20);

  test('an empty phone shows the workout and placeholders', () {
    final data = buildWidgetData(
      next: next,
      sessions: const [],
      settings: const AppSettings(),
      now: thu,
    );
    expect(data.nextTitle, '6 × 30 m');
    expect(data.nextName, 'Acceleration');
    expect(data.bestLabel, '30 m PB');
    expect(data.bestTime, '–');
    expect(data.bestNote, 'Time a rep to set one');
    expect(data.weekMetres, '0 m');
    expect(data.weekNote, '0 sessions');
    expect(data.today, 3);
  });

  test('best, monthly gain, and the week against reminder days', () {
    final data = buildWidgetData(
      next: next,
      sessions: [
        _s('new', [4.41, 4.5], DateTime(2026, 10, 28, 18)),
        _s('mon', [4.6], DateTime(2026, 10, 26, 18)),
        _s('60', [7.2], DateTime(2026, 10, 27, 18), d: 60),
        _s('old', [4.5], DateTime(2026, 9, 1)),
      ],
      settings: const AppSettings(reminderDays: {1, 3, 5}),
      now: thu,
    );
    expect(data.bestTime, '4.41');
    expect(data.bestNote, '−0.09 s this month');
    expect(data.weekDays, [30, 60, 60, 0, 0, 0, 0]);
    expect(data.weekMetres, '150 m');
    expect(data.weekNote, '3 of 3 sessions');
    expect(data.toMap()['week_days'], '30,60,60,0,0,0,0');
  });
}

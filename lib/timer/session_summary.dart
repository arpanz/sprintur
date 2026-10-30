import 'session_engine.dart';
import 'workout.dart';

class SessionSummary {
  const SessionSummary({
    required this.workout,
    required this.results,
    required this.finishedAt,
  });

  final Workout workout;
  final List<RepResult> results;
  final DateTime finishedAt;

  List<double> get measured => [
    for (final r in results)
      if (r.timeS != null) r.timeS!,
  ];

  double? get best {
    final m = measured;
    return m.isEmpty ? null : m.reduce((a, b) => a < b ? a : b);
  }

  double? get average {
    final m = measured;
    return m.isEmpty ? null : m.reduce((a, b) => a + b) / m.length;
  }

  int get onTargetCount => measured.where((t) => t <= workout.targetS).length;

  int get falseStarts => results.fold(0, (sum, r) => sum + r.falseStarts);

  int get metres => results.length * workout.distanceM;
}

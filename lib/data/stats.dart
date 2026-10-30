import 'database.dart';

/// Midnight on the Monday of [now]'s week, local time.
DateTime weekStart(DateTime now) {
  final day = DateTime(now.year, now.month, now.day);
  return day.subtract(Duration(days: day.weekday - 1));
}

/// Metres sprinted on each day of [now]'s week, Monday first.
List<int> weekMetres(List<StoredSession> sessions, DateTime now) {
  final start = weekStart(now);
  final days = List.filled(7, 0);
  for (final s in sessions) {
    final at = s.summary.finishedAt;
    final i = DateTime(at.year, at.month, at.day).difference(start).inDays;
    if (i >= 0 && i < 7) days[i] += s.summary.metres;
  }
  return days;
}

class PersonalBest {
  const PersonalBest({
    required this.distanceM,
    required this.timeS,
    required this.at,
  });

  final int distanceM;
  final double timeS;
  final DateTime at;
}

/// Fastest measured time per distance, shortest distance first.
List<PersonalBest> personalBests(List<StoredSession> sessions) {
  final best = <int, PersonalBest>{};
  for (final s in sessions) {
    final t = s.summary.best;
    if (t == null) continue;
    final d = s.summary.workout.distanceM;
    final current = best[d];
    if (current == null || t < current.timeS) {
      best[d] = PersonalBest(distanceM: d, timeS: t, at: s.summary.finishedAt);
    }
  }
  return best.values.toList()
    ..sort((a, b) => a.distanceM.compareTo(b.distanceM));
}

/// Ids of sessions that beat the previous best at their distance. The first
/// timed session at a distance sets a mark but is not counted as a PB.
Set<String> pbSessionIds(List<StoredSession> sessions) {
  final oldestFirst = [...sessions]
    ..sort((a, b) => a.summary.finishedAt.compareTo(b.summary.finishedAt));
  final best = <int, double>{};
  final ids = <String>{};
  for (final s in oldestFirst) {
    final t = s.summary.best;
    if (t == null) continue;
    final d = s.summary.workout.distanceM;
    final previous = best[d];
    if (previous != null && t < previous) ids.add(s.id);
    if (previous == null || t < previous) best[d] = t;
  }
  return ids;
}

/// The fastest time at [distanceM] across [sessions], or null if none.
double? bestAt(Iterable<StoredSession> sessions, int distanceM) {
  double? best;
  for (final s in sessions) {
    final t = s.summary.best;
    if (t == null || s.summary.workout.distanceM != distanceM) continue;
    if (best == null || t < best) best = t;
  }
  return best;
}

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../data/database.dart';
import '../data/settings.dart';
import '../data/stats.dart';
import '../timer/workout.dart';

/// Shared with the iOS widget extension.
const appGroupId = 'group.com.livinlabs.sprintur';

/// Android providers, in android/app/src/main/kotlin/.../widgets/.
const _androidProviders = [
  'com.livinlabs.sprintur.widgets.NextUpWidget',
  'com.livinlabs.sprintur.widgets.BestWidget',
  'com.livinlabs.sprintur.widgets.WeekWidget',
];

/// WidgetKit kinds, in ios/SprinturWidgets/.
const _iosKinds = ['NextUpWidget', 'BestWidget', 'WeekWidget'];

/// What the three home screen widgets show, already formatted, so the
/// native side only lays text out.
class WidgetData {
  const WidgetData({
    required this.nextTitle,
    required this.nextName,
    required this.bestLabel,
    required this.bestTime,
    required this.bestNote,
    required this.weekMetres,
    required this.weekNote,
    required this.weekDays,
    required this.today,
  });

  /// `6 × 30 m`
  final String nextTitle;
  final String nextName;

  /// `30 m PB`
  final String bestLabel;

  /// `4.41`, or `–` before any timed rep.
  final String bestTime;
  final String bestNote;

  /// `600 m`
  final String weekMetres;

  /// `2 of 3 sessions`
  final String weekNote;

  /// Metres per day, Monday first.
  final List<int> weekDays;

  /// 0 = Monday.
  final int today;

  Map<String, Object> toMap() => {
    'next_title': nextTitle,
    'next_name': nextName,
    'best_label': bestLabel,
    'best_time': bestTime,
    'best_note': bestNote,
    'week_metres': weekMetres,
    'week_note': weekNote,
    'week_days': weekDays.join(','),
    'week_today': today,
  };
}

WidgetData buildWidgetData({
  required Workout next,
  required List<StoredSession> sessions,
  required AppSettings settings,
  required DateTime now,
}) {
  final d = next.distanceM;
  final best = bestAt(sessions, d);
  final monthAgo = now.subtract(const Duration(days: 30));
  final before = bestAt(
    sessions.where((s) => s.summary.finishedAt.isBefore(monthAgo)),
    d,
  );
  final String bestNote;
  if (best == null) {
    bestNote = 'Time a rep to set one';
  } else if (before != null && best < before) {
    bestNote = '−${(before - best).toStringAsFixed(2)} s this month';
  } else {
    bestNote = 'Your fastest $d m';
  }

  final days = weekMetres(sessions, now);
  final start = weekStart(now);
  final count = sessions
      .where((s) => !s.summary.finishedAt.isBefore(start))
      .length;
  final goal = settings.reminderDays.length;
  final noun = (goal > 0 ? goal : count) == 1 ? 'session' : 'sessions';
  return WidgetData(
    nextTitle: '${next.reps} × $d m',
    nextName: next.name,
    bestLabel: '$d m PB',
    bestTime: best?.toStringAsFixed(2) ?? '–',
    bestNote: bestNote,
    weekMetres: '${days.fold(0, (a, b) => a + b)} m',
    weekNote: goal > 0 ? '$count of $goal $noun' : '$count $noun',
    weekDays: days,
    today: now.weekday - 1,
  );
}

class HomeWidgets {
  bool _groupSet = false;
  Map<String, Object>? _last;

  /// Saves [data] where the widgets read it and asks them to redraw.
  /// Skipped when nothing changed since the last call.
  Future<void> publish(WidgetData data) async {
    final map = data.toMap();
    if (mapEquals(map, _last)) return;
    _last = map;
    try {
      if (Platform.isIOS && !_groupSet) {
        await HomeWidget.setAppGroupId(appGroupId);
        _groupSet = true;
      }
      for (final e in map.entries) {
        await HomeWidget.saveWidgetData(e.key, e.value);
      }
      if (Platform.isAndroid) {
        for (final name in _androidProviders) {
          await HomeWidget.updateWidget(qualifiedAndroidName: name);
        }
      } else if (Platform.isIOS) {
        for (final kind in _iosKinds) {
          await HomeWidget.updateWidget(iOSName: kind);
        }
      }
    } catch (e) {
      debugPrint('Home widget update failed: $e');
    }
  }
}

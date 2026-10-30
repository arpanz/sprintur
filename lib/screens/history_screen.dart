import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/providers.dart';
import '../app/theme.dart';
import '../data/database.dart';
import '../data/stats.dart';
import '../widgets/common.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  bool _records = false;

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(sessionsProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text('HISTORY', style: SprintText.display(40)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: _Segmented(
                labels: const ['Sessions', 'Records'],
                index: _records ? 1 : 0,
                onChanged: (i) => setState(() => _records = i == 1),
              ),
            ),
            Expanded(
              child: sessions.when(
                loading: () => const SizedBox.shrink(),
                error: (e, _) => _Empty(text: 'Could not load history: $e'),
                data: (all) => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _records
                      ? _RecordsList(key: const ValueKey('r'), sessions: all)
                      : _SessionList(key: const ValueKey('s'), sessions: all),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: SprintColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final (i, label) in labels.indexed)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == index,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onChanged(i);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == index
                          ? SprintColors.line
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: i == index
                            ? SprintColors.text
                            : SprintColors.muted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
            color: SprintColors.muted,
          ),
        ),
      ),
    );
  }
}

class _SessionList extends StatelessWidget {
  const _SessionList({super.key, required this.sessions});

  final List<StoredSession> sessions;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const _Empty(
        text: 'No sessions yet.\nFinish a workout and it shows up here.',
      );
    }
    final pbs = pbSessionIds(sessions);
    final thisWeek = weekStart(DateTime.now());
    final lastWeek = thisWeek.subtract(const Duration(days: 7));

    String groupOf(DateTime at) {
      final start = weekStart(at);
      if (start == thisWeek) return 'This week';
      if (start == lastWeek) return 'Last week';
      return 'Week of ${formatDay(start)}';
    }

    final children = <Widget>[];
    String? group;
    for (final s in sessions) {
      final g = groupOf(s.summary.finishedAt);
      if (g != group) {
        group = g;
        children.add(
          Padding(
            padding: EdgeInsets.only(top: children.isEmpty ? 0 : 18, bottom: 8),
            child: Text(g.toUpperCase(), style: SprintText.label),
          ),
        );
      }
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _SessionCard(session: s, pb: pbs.contains(s.id)),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: children,
    );
  }
}

class _SessionCard extends ConsumerWidget {
  const _SessionCard({required this.session, required this.pb});

  final StoredSession session;
  final bool pb;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = session.summary;
    final w = s.workout;
    final best = s.best;
    final meta = [
      weekdayNames[s.finishedAt.weekday - 1].substring(0, 3),
      formatClock(s.finishedAt),
      if (session.rpe != null) 'RPE ${session.rpe}',
    ].join(' · ');

    return Dismissible(
      key: ValueKey(session.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => ref.read(databaseProvider).deleteSession(session.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: SprintColors.orange.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: SprintColors.orangeText,
        ),
      ),
      child: Material(
        color: SprintColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: SprintColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/session', extra: session),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _MiniBars(session: session),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${w.name} ${s.results.length} × ${w.distanceM} m',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        meta,
                        style: const TextStyle(
                          fontSize: 12,
                          color: SprintColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      best != null ? best.toStringAsFixed(2) : '${s.metres} m',
                      style: SprintText.number(22),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pb ? 'New PB' : (best != null ? 'Best' : 'Volume'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: pb ? SprintColors.lime : SprintColors.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this session?'),
        content: const Text('It is removed from your history and records.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: SprintColors.textSoft),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: SprintColors.orangeText),
            ),
          ),
        ],
      ),
    );
    return ok ?? false;
  }
}

/// Tiny rep chart: taller is faster. Untimed reps are equal grey bars.
class _MiniBars extends StatelessWidget {
  const _MiniBars({required this.session});

  final StoredSession session;

  @override
  Widget build(BuildContext context) {
    final s = session.summary;
    final target = s.workout.targetS;
    final results = s.results.take(10).toList();
    // At most 8 px wide, so a session of one or two reps stays a chart.
    final barWidth = results.isEmpty
        ? 0.0
        : ((56 - 3 * (results.length - 1)) / results.length).clamp(2.0, 8.0);
    return ExcludeSemantics(
      child: SizedBox(
        width: 56,
        height: 36,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final (i, r) in results.indexed) ...[
              if (i > 0) const SizedBox(width: 3),
              SizedBox(
                width: barWidth,
                child: Container(
                  height: r.timeS == null
                      ? 18
                      : (36 - (r.timeS! / target - 0.9) * 180).clamp(6, 36),
                  decoration: BoxDecoration(
                    color: r.timeS == null
                        ? SprintColors.line
                        : r.timeS! <= target
                        ? SprintColors.lime
                        : SprintColors.orange,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecordsList extends StatelessWidget {
  const _RecordsList({super.key, required this.sessions});

  final List<StoredSession> sessions;

  @override
  Widget build(BuildContext context) {
    final records = personalBests(sessions);
    if (records.isEmpty) {
      return const _Empty(
        text:
            'No records yet.\nTurn on "Partner taps finish" in the builder '
            'to record real times.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: records.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final r = records[i];
        return SectionCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${r.distanceM} m',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatDay(r.at),
                      style: const TextStyle(
                        fontSize: 12,
                        color: SprintColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                r.timeS.toStringAsFixed(2),
                style: SprintText.number(
                  32,
                  color: SprintColors.lime,
                ).copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        );
      },
    );
  }
}

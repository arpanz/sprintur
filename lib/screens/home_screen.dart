import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/providers.dart';
import '../app/theme.dart';
import '../data/database.dart';
import '../data/stats.dart';
import '../timer/workout.dart';
import '../widgets/common.dart';

const _presetIcons = [
  Icons.bolt_rounded,
  Icons.flag_rounded,
  Icons.graphic_eq_rounded,
  Icons.timer_outlined,
];

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.watch(workoutProvider);
    final saved = ref.watch(savedWorkoutsProvider).value ?? const [];
    final sessions = ref.watch(sessionsProvider).value ?? const [];
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Text(
              weekdayNames[DateTime.now().weekday - 1],
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: SprintColors.muted,
              ),
            ),
            const SizedBox(height: 4),
            Text('READY TO FLY?', style: SprintText.display(34)),
            const SizedBox(height: 22),
            _HeroCard(workout: workout),
            const SizedBox(height: 26),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Quick start',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/builder'),
                  child: const Text('Build your own'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mainAxisExtent: 124,
              ),
              children: [
                for (final (i, preset) in Workout.presets.indexed)
                  _PresetCard(
                    workout: preset,
                    icon: _presetIcons[i % _presetIcons.length],
                    selected: preset == workout,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref.read(workoutProvider.notifier).set(preset);
                    },
                  ),
                for (final (id, w) in saved)
                  _PresetCard(
                    workout: w,
                    icon: Icons.bookmark_rounded,
                    selected: w == workout,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref.read(workoutProvider.notifier).set(w);
                    },
                    onLongPress: () => _confirmDelete(context, ref, id, w),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _WeekCard(sessions: sessions),
          ],
        ),
      ),
    );
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  String id,
  Workout w,
) async {
  HapticFeedback.mediumImpact();
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Remove "${w.name}"?'),
      content: const Text('Sessions you ran with it stay in your history.'),
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
            'Remove',
            style: TextStyle(color: SprintColors.orangeText),
          ),
        ),
      ],
    ),
  );
  if (ok == true) await ref.read(databaseProvider).deleteWorkout(id);
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.sessions});

  final List<StoredSession> sessions;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = weekMetres(sessions, now);
    final total = days.fold(0, (a, b) => a + b);
    final start = weekStart(now);
    final thisWeek = sessions
        .where((s) => !s.summary.finishedAt.isBefore(start))
        .toList();
    final best = thisWeek
        .where((s) => s.summary.best != null)
        .fold<(double, int)?>(null, (acc, s) {
          final t = s.summary.best!;
          return acc == null || t < acc.$1
              ? (t, s.summary.workout.distanceM)
              : acc;
        });
    final peak = days.fold(1, (a, b) => a > b ? a : b);
    final today = now.weekday - 1;
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return SectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('THIS WEEK', style: SprintText.label),
                const SizedBox(height: 4),
                Text('$total m', style: SprintText.number(38)),
                const SizedBox(height: 4),
                Text(
                  [
                    '${thisWeek.length} '
                        '${thisWeek.length == 1 ? 'session' : 'sessions'}',
                    if (best != null)
                      'best ${best.$2} m ${best.$1.toStringAsFixed(2)} s',
                  ].join(' · '),
                  style: const TextStyle(
                    fontSize: 12,
                    color: SprintColors.muted,
                  ),
                ),
              ],
            ),
          ),
          ExcludeSemantics(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < 7; i++) ...[
                  if (i > 0) const SizedBox(width: 7),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(
                          end: days[i] == 0 ? 4 : 4 + days[i] / peak * 52,
                        ),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        builder: (context, h, _) => Container(
                          width: 12,
                          height: h,
                          decoration: BoxDecoration(
                            color: i == today
                                ? SprintColors.lime
                                : days[i] > 0
                                ? SprintColors.text
                                : SprintColors.line,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: i == today
                              ? SprintColors.lime
                              : SprintColors.muted,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.workout});

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final chips = [
      'Target ${workout.targetS.toStringAsFixed(2)} s',
      'Rest ${formatRest(workout.restS)}',
      workout.splitEveryM > 0
          ? 'Beep every ${workout.splitEveryM} m'
          : 'No split beeps',
      if (workout.finishMode == FinishMode.tap) 'Partner taps finish',
    ];
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: SprintColors.lime,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'NEXT UP',
            style: SprintText.label.copyWith(color: SprintColors.bg),
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOutCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween(begin: 0.96, end: 1.0).animate(animation),
                alignment: Alignment.centerLeft,
                child: child,
              ),
            ),
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topLeft,
              children: [...previous, ?current],
            ),
            child: Column(
              key: ValueKey(workout),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${workout.reps} × ${workout.distanceM} m\n'
                  '${workout.name.toUpperCase()}',
                  style: SprintText.display(
                    56,
                    color: SprintColors.bg,
                  ).copyWith(height: 0.88),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [for (final c in chips) _OutlineChip(c)],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          BigButton(
            label: 'Start session',
            icon: Icons.play_arrow_rounded,
            background: SprintColors.bg,
            foreground: SprintColors.text,
            onPressed: () => context.push('/live'),
          ),
        ],
      ),
    );
  }
}

class _OutlineChip extends StatelessWidget {
  const _OutlineChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(
          color: SprintColors.bg.withValues(alpha: 0.35),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: SprintColors.bg,
        ),
      ),
    );
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({
    required this.workout,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.onLongPress,
  });

  final Workout workout;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: SprintColors.surface,
            border: Border.all(
              color: selected ? SprintColors.lime : SprintColors.border,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: SprintColors.lime, size: 22),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${workout.reps} × ${workout.distanceM} m · '
                    'rest ${formatRest(workout.restS)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: SprintColors.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

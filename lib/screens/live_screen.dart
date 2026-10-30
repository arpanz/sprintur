import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../app/providers.dart';
import '../app/theme.dart';
import '../audio/cue_player.dart';
import '../timer/session_driver.dart';
import '../timer/session_engine.dart';
import '../timer/session_summary.dart';
import '../timer/workout.dart';
import '../widgets/common.dart';
import '../widgets/session_visuals.dart';

const _phaseLabels = {
  Phase.ready: 'GET READY',
  Phase.leadIn: 'GET TO THE LINE',
  Phase.marks: 'ON YOUR MARKS',
  Phase.set: 'SET',
  Phase.running: 'GO',
  Phase.rest: 'REST',
  Phase.done: 'SESSION DONE',
};

class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({super.key});

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen>
    with SingleTickerProviderStateMixin {
  late final CuePlayer _player;
  late final SessionDriver _driver;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _player = ref.read(cuePlayerProvider);
    _driver = SessionDriver(
      workout: ref.read(workoutProvider),
      onCue: _player.play,
    )..addListener(_onPhase);
    _ticker = createTicker((_) => setState(() {}));
    WakelockPlus.enable();
  }

  /// The clock only needs repainting every frame while something is counting.
  void _onPhase() {
    final counting = switch (_driver.state.phase) {
      Phase.ready || Phase.done => false,
      _ => true,
    };
    if (counting && !_ticker.isActive) _ticker.start();
    if (!counting && _ticker.isActive) _ticker.stop();
    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    _driver.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  SessionSummary get _summary => SessionSummary(
    workout: _driver.workout,
    results: _driver.state.results,
    finishedAt: DateTime.now(),
  );

  Future<void> _confirmEnd() async {
    final end = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End session?'),
        content: const Text('Reps you have finished are kept in the summary.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Keep going',
              style: TextStyle(color: SprintColors.textSoft),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('End'),
          ),
        ],
      ),
    );
    if (end != true || !mounted) return;
    _driver.stop();
    if (_driver.state.results.isEmpty) {
      context.pop();
    } else {
      context.pushReplacement('/summary', extra: _summary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _driver.state;
    final w = _driver.workout;
    final now = _driver.now;
    final elapsed = s.runElapsedS(now);
    final idle = s.phase == Phase.ready || s.phase == Phase.done;

    return PopScope(
      canPop: idle,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmEnd();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: s.phase == Phase.set ? SprintColors.setBg : SprintColors.bg,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          // A partner timing the finish taps in a hurry: anywhere on the
          // screen counts, not only the button.
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: s.phase == Phase.running && w.finishMode == FinishMode.tap
                ? _driver.tap
                : null,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  children: [
                    _TopBar(
                      workout: w,
                      state: s,
                      muted: _player.muted,
                      onClose: idle && s.results.isEmpty
                          ? () => context.pop()
                          : _confirmEnd,
                      onMute: () =>
                          setState(() => _player.muted = !_player.muted),
                    ),
                    const SizedBox(height: 18),
                    _RepSegments(workout: w, state: s),
                    const Spacer(),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (child, a) => FadeTransition(
                        opacity: a,
                        child: ScaleTransition(
                          scale: Tween(begin: 0.85, end: 1.0).animate(a),
                          child: child,
                        ),
                      ),
                      child: Text(
                        _phaseLabels[s.phase]!,
                        key: ValueKey(s.phase),
                        textAlign: TextAlign.center,
                        style: SprintText.display(
                          40,
                          color: switch (s.phase) {
                            Phase.running => SprintColors.lime,
                            Phase.set => SprintColors.text,
                            _ => SprintColors.textSoft,
                          },
                        ).copyWith(letterSpacing: 1),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Clock(workout: w, state: s, now: now, elapsed: elapsed),
                    const Spacer(),
                    TrackStrip(
                      workout: w,
                      elapsedS: elapsed,
                      complete: s.phase == Phase.rest || s.phase == Phase.done,
                    ),
                    const SizedBox(height: 12),
                    _LastRep(workout: w, state: s),
                    const SizedBox(height: 12),
                    _ActionButton(
                      workout: w,
                      phase: s.phase,
                      onStart: _driver.start,
                      onTap: _driver.tap,
                      onSummary: () =>
                          context.pushReplacement('/summary', extra: _summary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.workout,
    required this.state,
    required this.muted,
    required this.onClose,
    required this.onMute,
  });

  final Workout workout;
  final SessionState state;
  final bool muted;
  final VoidCallback onClose;
  final VoidCallback onMute;

  @override
  Widget build(BuildContext context) {
    final done = state.phase == Phase.done;
    return Row(
      children: [
        RoundIconButton(
          icon: Icons.close_rounded,
          tooltip: 'End session',
          onPressed: onClose,
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                '${workout.name} · ${workout.distanceM} m'.toUpperCase(),
                style: SprintText.label,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                done
                    ? '${state.results.length} of ${workout.reps} done'
                    : 'Rep ${state.rep} of ${workout.reps}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        RoundIconButton(
          icon: muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
          tooltip: muted ? 'Unmute beeps' : 'Mute beeps',
          onPressed: onMute,
        ),
      ],
    );
  }
}

class _RepSegments extends StatelessWidget {
  const _RepSegments({required this.workout, required this.state});

  final Workout workout;
  final SessionState state;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        children: [
          for (var i = 1; i <= workout.reps; i++) ...[
            if (i > 1) const SizedBox(width: 6),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 6,
                decoration: BoxDecoration(
                  color: _color(i),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _color(int rep) {
    if (rep <= state.results.length) {
      final t = state.results[rep - 1].timeS;
      return t != null && t > workout.targetS
          ? SprintColors.orange
          : SprintColors.lime;
    }
    if (rep == state.rep && state.phase != Phase.done) return SprintColors.text;
    return SprintColors.line;
  }
}

class _Clock extends StatelessWidget {
  const _Clock({
    required this.workout,
    required this.state,
    required this.now,
    required this.elapsed,
  });

  final Workout workout;
  final SessionState state;
  final Duration now;
  final double elapsed;

  @override
  Widget build(BuildContext context) {
    final target = 'Target ${workout.targetS.toStringAsFixed(2)} s';
    final left = state.secondsLeft(now);
    final phaseLength = state.phaseEndsAt == null
        ? null
        : (state.phaseEndsAt! - state.phaseStartedAt).inMicroseconds / 1e6;
    final summary = SessionSummary(
      workout: workout,
      results: state.results,
      finishedAt: DateTime.now(),
    );

    final (
      String big,
      String sub,
      double progress,
      Color color,
    ) = switch (state.phase) {
      Phase.running => (
        elapsed.toStringAsFixed(2),
        target,
        elapsed / workout.targetS,
        elapsed > workout.targetS ? SprintColors.orange : SprintColors.lime,
      ),
      Phase.leadIn => (
        '${(left ?? 0).ceil()}',
        'Walk to the start line',
        phaseLength == null ? 0 : (left ?? 0) / phaseLength,
        SprintColors.lime,
      ),
      Phase.rest => (
        formatRest((left ?? 0).ceil()),
        'Next: rep ${state.rep} of ${workout.reps}',
        phaseLength == null ? 0 : (left ?? 0) / phaseLength,
        SprintColors.text,
      ),
      Phase.done =>
        summary.best != null
            ? (
                summary.best!.toStringAsFixed(2),
                'Best time',
                1,
                SprintColors.lime,
              )
            : (
                '${state.results.length}/${workout.reps}',
                'Reps done',
                1,
                SprintColors.lime,
              ),
      _ => (workout.targetS.toStringAsFixed(2), target, 0, SprintColors.lime),
    };

    return Semantics(
      liveRegion: state.phase != Phase.running,
      label: '$big. $sub',
      child: ExcludeSemantics(
        child: ProgressRing(
          progress: progress,
          color: color,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(big, style: SprintText.number(104)),
              ),
              const SizedBox(height: 4),
              Text(
                sub,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: SprintColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LastRep extends StatelessWidget {
  const _LastRep({required this.workout, required this.state});

  final Workout workout;
  final SessionState state;

  @override
  Widget build(BuildContext context) {
    const muted = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: SprintColors.muted,
    );
    Widget left;
    Widget? right;
    if (state.falseStartsThisRep > 0 && state.phase != Phase.rest) {
      left = const Text(
        'False start · go again',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: SprintColors.orangeText,
        ),
      );
    } else if (state.results.isEmpty) {
      left = Text(
        workout.splitDistances.isEmpty
            ? 'No split beeps. The target time beeps.'
            : 'Beeps sound at each cone on target pace',
        style: muted,
      );
    } else {
      final last = state.results.last;
      final t = last.timeS;
      if (t != null) {
        final delta = t - workout.targetS;
        left = Text(
          'Rep ${last.rep} · ${t.toStringAsFixed(2)} s',
          style: muted,
        );
        right = Text(
          formatDelta(delta),
          style: SprintText.number(
            24,
            color: delta <= 0 ? SprintColors.lime : SprintColors.orange,
          ),
        );
      } else {
        left = Text('Rep ${last.rep} done', style: muted);
        right = const Text('On the beep', style: muted);
      }
    }
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          Expanded(child: left),
          ?right,
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.workout,
    required this.phase,
    required this.onStart,
    required this.onTap,
    required this.onSummary,
  });

  final Workout workout;
  final Phase phase;
  final VoidCallback onStart;
  final VoidCallback onTap;
  final VoidCallback onSummary;

  @override
  Widget build(BuildContext context) {
    const height = 76.0;
    const radius = 24.0;
    final tapMode = workout.finishMode == FinishMode.tap;
    final Widget button = switch (phase) {
      Phase.ready => BigButton(
        label: 'START',
        display: true,
        height: height,
        radius: radius,
        onPressed: onStart,
      ),
      Phase.leadIn => const BigButton(
        label: 'Starting…',
        outlined: true,
        foreground: SprintColors.muted,
        height: height,
        radius: radius,
        onPressed: null,
      ),
      Phase.marks || Phase.set => BigButton(
        label: 'Hold still. Tapping now is a false start',
        outlined: true,
        foreground: SprintColors.muted,
        height: height,
        radius: radius,
        onPressed: onTap,
      ),
      Phase.running when tapMode => BigButton(
        label: 'TAP AT THE FINISH',
        display: true,
        background: SprintColors.text,
        height: height,
        radius: radius,
        onPressed: onTap,
      ),
      Phase.running => const BigButton(
        label: 'Run to the beep',
        outlined: true,
        foreground: SprintColors.muted,
        height: height,
        radius: radius,
        onPressed: null,
      ),
      Phase.rest => BigButton(
        label: 'Skip rest',
        background: SprintColors.surface,
        foreground: SprintColors.text,
        height: height,
        radius: radius,
        onPressed: onTap,
      ),
      Phase.done => BigButton(
        label: 'SEE SUMMARY',
        display: true,
        height: height,
        radius: radius,
        onPressed: onSummary,
      ),
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: KeyedSubtree(key: ValueKey((phase, tapMode)), child: button),
    );
  }
}

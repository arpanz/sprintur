import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/providers.dart';
import '../app/theme.dart';
import '../timer/session_summary.dart';
import '../widgets/common.dart';

/// Shows a session. A fresh one (no [sessionId]) is saved as soon as the
/// screen opens, so nothing is lost if the app is closed here. One opened
/// from History can be rated again or deleted.
class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({
    super.key,
    required this.summary,
    this.sessionId,
    this.rpe,
  });

  final SessionSummary summary;
  final String? sessionId;
  final int? rpe;

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  late final Future<String> _id;
  int? _rpe;

  bool get _fromHistory => widget.sessionId != null;

  @override
  void initState() {
    super.initState();
    _rpe = widget.rpe;
    _id = _fromHistory
        ? Future.value(widget.sessionId)
        : ref.read(databaseProvider).saveSession(widget.summary);
  }

  Future<void> _rate(int value) async {
    final next = _rpe == value ? null : value;
    setState(() => _rpe = next);
    await ref.read(databaseProvider).setRpe(await _id, next);
  }

  Future<void> _delete() async {
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
    if (ok != true || !mounted) return;
    await ref.read(databaseProvider).deleteSession(await _id);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final w = summary.workout;
    final at = summary.finishedAt;
    final hasTimes = summary.measured.isNotEmpty;

    final tiles = hasTimes
        ? [
            ('Best', summary.best!.toStringAsFixed(2)),
            ('Average', summary.average!.toStringAsFixed(2)),
            (
              'On target',
              '${summary.onTargetCount}/${summary.measured.length}',
            ),
          ]
        : [
            ('Reps', '${summary.results.length}'),
            ('Metres', '${summary.metres}'),
            ('False starts', '${summary.falseStarts}'),
          ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${formatDay(at)} · ${formatClock(at)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: SprintColors.muted,
                          ),
                        ),
                      ),
                      if (_fromHistory)
                        RoundIconButton(
                          icon: Icons.delete_outline_rounded,
                          tooltip: 'Delete session',
                          onPressed: _delete,
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _fromHistory ? w.name.toUpperCase() : 'SESSION DONE',
                    style: SprintText.display(44),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _fromHistory
                        ? '${summary.results.length} of ${w.reps} × ${w.distanceM} m'
                        : '${w.name} · ${w.reps} × ${w.distanceM} m',
                    style: const TextStyle(
                      fontSize: 15,
                      color: SprintColors.textSoft,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      for (final (i, (label, value)) in tiles.indexed) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(
                          child: _StatTile(
                            label: label,
                            value: value,
                            highlight: i == 0,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (hasTimes)
                    _RepChart(summary: summary)
                  else
                    const SectionCard(
                      child: Text(
                        'Times are only recorded when a partner taps the '
                        'finish. Turn it on in the builder.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: SprintColors.textSoft,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  _EffortPicker(value: _rpe, onPick: _rate),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: BigButton(
                label: 'Done',
                onPressed: () => _fromHistory ? context.pop() : context.go('/'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EffortPicker extends StatelessWidget {
  const _EffortPicker({required this.value, required this.onPick});

  final int? value;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How hard was it?',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var n = 1; n <= 10; n++) ...[
              if (n > 1) const SizedBox(width: 4),
              Expanded(
                child: Semantics(
                  button: true,
                  selected: value == n,
                  label: 'Effort $n of 10',
                  excludeSemantics: true,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onPick(n);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: value == n
                            ? SprintColors.text
                            : SprintColors.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$n',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: value == n
                              ? SprintColors.bg
                              : SprintColors.textSoft,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.highlight,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final fg = highlight ? SprintColors.bg : SprintColors.text;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlight ? SprintColors.lime : SprintColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label.toUpperCase(),
              style: SprintText.label.copyWith(
                fontSize: 11,
                letterSpacing: 0.6,
                color: highlight ? SprintColors.bg : SprintColors.muted,
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: SprintText.number(34, color: fg)),
          ),
        ],
      ),
    );
  }
}

class _RepChart extends StatelessWidget {
  const _RepChart({required this.summary});

  final SessionSummary summary;
  static const _plotHeight = 130.0;

  @override
  Widget build(BuildContext context) {
    final target = summary.workout.targetS;
    final times = summary.measured;
    // Include the target so its line stays on the chart even when every
    // rep missed it.
    final lo = min(times.reduce(min), target) * 0.85;
    final hi = max(times.reduce(max), target) * 1.05;
    double h(double t) =>
        ((t - lo) / (hi - lo) * _plotHeight).clamp(4, _plotHeight);
    final results = summary.results;

    return Semantics(
      label:
          'Rep times against a ${target.toStringAsFixed(2)} second target: '
          '${times.map((t) => t.toStringAsFixed(2)).join(', ')}',
      child: ExcludeSemantics(
        child: SectionCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rep times',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Target ${target.toStringAsFixed(2)} s',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: SprintColors.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: _plotHeight + 22,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: h(target),
                      child: const _DashedLine(),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final (i, r) in results.indexed) ...[
                          if (i > 0) const SizedBox(width: 10),
                          Expanded(
                            // Few reps should not turn into slabs.
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 48),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: _Bar(
                                    index: i,
                                    timeS: r.timeS,
                                    height: r.timeS == null ? 4 : h(r.timeS!),
                                    onTarget:
                                        r.timeS != null && r.timeS! <= target,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  for (final (i, r) in results.indexed) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${r.rep}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          color: SprintColors.muted,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.index,
    required this.timeS,
    required this.height,
    required this.onTarget,
  });

  final int index;
  final double? timeS;
  final double height;
  final bool onTarget;

  @override
  Widget build(BuildContext context) {
    final color = timeS == null
        ? SprintColors.line
        : onTarget
        ? SprintColors.lime
        : SprintColors.orange;
    final delay = index * 60;
    const grow = 600;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: grow + delay),
      curve: Interval(delay / (grow + delay), 1, curve: Curves.easeOutCubic),
      builder: (context, v, _) => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Opacity(
            opacity: v,
            child: Text(
              timeS?.toStringAsFixed(2) ?? '–',
              style: SprintText.number(
                12,
                color: onTarget || timeS == null
                    ? SprintColors.text
                    : SprintColors.orangeText,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: height * v,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
                bottom: Radius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size.fromHeight(2), painter: _DashPainter());
  }
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6B7280)
      ..strokeWidth = 1.5;
    for (var x = 0.0; x < size.width; x += 8) {
      canvas.drawLine(Offset(x, 0), Offset(min(x + 4, size.width), 0), paint);
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => false;
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/theme.dart';
import '../timer/session_summary.dart';
import '../widgets/common.dart';

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key, required this.summary});

  final SessionSummary summary;

  @override
  Widget build(BuildContext context) {
    final w = summary.workout;
    final at = summary.finishedAt;
    final time =
        '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';
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
                  Text(
                    '${at.day} ${_months[at.month - 1]} · $time',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: SprintColors.muted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('SESSION DONE', style: SprintText.display(44)),
                  const SizedBox(height: 6),
                  Text(
                    '${w.name} · ${w.reps} × ${w.distanceM} m',
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
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: BigButton(label: 'Done', onPressed: () => context.go('/')),
            ),
          ],
        ),
      ),
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
    final lo = times.reduce(min) * 0.85;
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
                            child: _Bar(
                              index: i,
                              timeS: r.timeS,
                              height: r.timeS == null ? 4 : h(r.timeS!),
                              onTarget: r.timeS != null && r.timeS! <= target,
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

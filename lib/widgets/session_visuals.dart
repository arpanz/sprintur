import 'dart:math';

import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../timer/workout.dart';

/// Progress ring starting at 12 o'clock.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    required this.color,
    required this.child,
    this.size = 300,
  });

  final double progress;
  final Color color;
  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: color),
        duration: const Duration(milliseconds: 200),
        builder: (context, c, _) => CustomPaint(
          painter: _RingPainter(progress.clamp(0, 1), c ?? color),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress, this.color);

  final double progress;
  final Color color;
  static const _stroke = 14.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(_stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      rect,
      0,
      2 * pi,
      false,
      paint..color = SprintColors.surface2,
    );
    if (progress > 0) {
      canvas.drawArc(
        rect,
        -pi / 2,
        2 * pi * progress,
        false,
        paint..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}

/// The track with a dot per cone. A dot lights up once the runner should
/// have passed it.
class TrackStrip extends StatelessWidget {
  const TrackStrip({
    super.key,
    required this.workout,
    required this.elapsedS,
    required this.complete,
  });

  final Workout workout;
  final double elapsedS;

  /// Rep finished: everything lit.
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final marks = [0, ...workout.splitDistances, workout.distanceM];
    final fill = complete ? 1.0 : (elapsedS / workout.targetS).clamp(0.0, 1.0);
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        decoration: BoxDecoration(
          color: SprintColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 22,
              child: LayoutBuilder(
                builder: (context, box) {
                  final trackW = box.maxWidth - 16;
                  return Stack(
                    children: [
                      Positioned(
                        left: 8,
                        right: 8,
                        top: 9,
                        child: Container(height: 4, color: SprintColors.line),
                      ),
                      Positioned(
                        left: 8,
                        top: 9,
                        child: Container(
                          height: 4,
                          width: trackW * fill,
                          color: SprintColors.lime,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (final d in marks)
                            _Dot(
                              lit:
                                  complete ||
                                  (elapsedS > 0 &&
                                      elapsedS >= workout.targetTimeAt(d)),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final d in marks)
                  Text(
                    '$d m',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: SprintColors.muted,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.lit});

  final bool lit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 22,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: lit ? SprintColors.lime : const Color(0xFF3A3F48),
            boxShadow: [
              if (lit)
                BoxShadow(
                  color: SprintColors.lime.withValues(alpha: 0.25),
                  spreadRadius: 4,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

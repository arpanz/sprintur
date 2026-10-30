import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/providers.dart';
import '../app/theme.dart';
import '../timer/workout.dart';
import '../widgets/common.dart';

const _splitChoices = [5, 10, 20, 25, 0];

class BuilderScreen extends ConsumerWidget {
  const BuilderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = ref.watch(workoutProvider);
    void update(Workout next) => ref.read(workoutProvider.notifier).set(next);
    final minutes = ((w.reps * (w.targetS + w.restS + 8)) / 60).round().clamp(
      1,
      999,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  RoundIconButton(
                    icon: Icons.chevron_left_rounded,
                    tooltip: 'Back',
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('WORKOUT SETUP', style: SprintText.label),
                        const SizedBox(height: 2),
                        Text(
                          w.name.toUpperCase(),
                          style: SprintText.display(24),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                children: [
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          mainAxisExtent: 104,
                        ),
                    children: [
                      _StepperCard(
                        label: 'Reps',
                        value: '${w.reps}',
                        onStep: (dir) => update(
                          w.copyWith(reps: (w.reps + dir).clamp(1, 30)),
                        ),
                      ),
                      _StepperCard(
                        label: 'Distance',
                        value: '${w.distanceM}',
                        unit: 'm',
                        onStep: (dir) => update(
                          w.copyWith(
                            distanceM: (w.distanceM + dir * 5).clamp(10, 400),
                          ),
                        ),
                      ),
                      _StepperCard(
                        label: 'Target time',
                        value: w.targetS.toStringAsFixed(2),
                        unit: 's',
                        onStep: (dir) {
                          final tenths = (w.targetS * 10).round() + dir;
                          update(
                            w.copyWith(targetS: tenths.clamp(10, 900) / 10),
                          );
                        },
                      ),
                      _StepperCard(
                        label: 'Rest',
                        value: formatRest(w.restS),
                        onStep: (dir) => update(
                          w.copyWith(
                            restS: (w.restS + dir * 15).clamp(15, 900),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SectionCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Split beeps',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            for (final (i, s) in _splitChoices.indexed) ...[
                              if (i > 0) const SizedBox(width: 6),
                              Expanded(
                                child: ChoiceChipButton(
                                  label: s == 0 ? 'Off' : '$s m',
                                  selected: w.splitEveryM == s,
                                  onTap: () =>
                                      update(w.copyWith(splitEveryM: s)),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        _ConePreview(workout: w),
                        const SizedBox(height: 10),
                        Text(
                          w.splitEveryM > 0
                              ? 'Set a cone every ${w.splitEveryM} m. A beep '
                                    'sounds when you should be passing each one.'
                              : 'Only the start and the target time beep.',
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: SprintColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SectionCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Column(
                      children: [
                        _ToggleRow(
                          label: 'Start signal',
                          sub: 'Marks, set, then go after 1.5 to 3 s',
                          value: w.startSignal,
                          onChanged: (v) => update(w.copyWith(startSignal: v)),
                        ),
                        const Divider(height: 1, color: SprintColors.border),
                        _ToggleRow(
                          label: 'Partner taps finish',
                          sub:
                              'Records real times. Off: the rep ends on '
                              'the target beep',
                          value: w.finishMode == FinishMode.tap,
                          onChanged: (v) => update(
                            w.copyWith(
                              finishMode: v ? FinishMode.tap : FinishMode.auto,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              decoration: const BoxDecoration(
                color: SprintColors.navBg,
                border: Border(top: BorderSide(color: Color(0xFF1C1F24))),
              ),
              child: Column(
                children: [
                  DefaultTextStyle.merge(
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: SprintColors.muted,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '${w.reps} reps · ${w.totalDistanceM} m total',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('about $minutes min'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  BigButton(
                    label: 'Start workout',
                    icon: Icons.play_arrow_rounded,
                    onPressed: () => context.push('/live'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperCard extends StatelessWidget {
  const _StepperCard({
    required this.label,
    required this.value,
    required this.onStep,
    this.unit,
  });

  final String label;
  final String value;
  final String? unit;
  final ValueChanged<int> onStep;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: SprintColors.muted,
            ),
          ),
          Row(
            children: [
              _RepeatButton(
                icon: Icons.remove_rounded,
                tooltip: 'Decrease $label',
                onStep: () => onStep(-1),
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: value, style: SprintText.number(30)),
                        if (unit != null)
                          TextSpan(
                            text: ' $unit',
                            style: SprintText.number(
                              15,
                              color: SprintColors.muted,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              _RepeatButton(
                icon: Icons.add_rounded,
                tooltip: 'Increase $label',
                onStep: () => onStep(1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Steps once on tap and keeps stepping while held.
class _RepeatButton extends StatefulWidget {
  const _RepeatButton({
    required this.icon,
    required this.tooltip,
    required this.onStep,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onStep;

  @override
  State<_RepeatButton> createState() => _RepeatButtonState();
}

class _RepeatButtonState extends State<_RepeatButton> {
  Timer? _delay;
  Timer? _repeat;

  void _down() {
    HapticFeedback.selectionClick();
    widget.onStep();
    _delay = Timer(const Duration(milliseconds: 350), () {
      _repeat = Timer.periodic(
        const Duration(milliseconds: 90),
        (_) => widget.onStep(),
      );
    });
  }

  void _up() {
    _delay?.cancel();
    _repeat?.cancel();
  }

  @override
  void dispose() {
    _up();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.tooltip,
      onTap: widget.onStep,
      child: GestureDetector(
        onTapDown: (_) => _down(),
        onTapUp: (_) => _up(),
        onTapCancel: _up,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: SprintColors.surface2,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(widget.icon, size: 22, color: SprintColors.text),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.sub,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String sub;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 60),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: const TextStyle(
                      fontSize: 12,
                      color: SprintColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          SprintSwitch(value: value, onChanged: onChanged, label: label),
        ],
      ),
    );
  }
}

/// Cones along a line with the target time at each one.
class _ConePreview extends StatelessWidget {
  const _ConePreview({required this.workout});

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    var marks = [0, ...workout.splitDistances, workout.distanceM];
    if (marks.length > 9) {
      final every = (marks.length / 9).ceil();
      marks = [
        for (final (i, d) in marks.indexed)
          if (i % every == 0 || d == workout.distanceM) d,
      ];
    }
    return SizedBox(
      height: 58,
      child: Stack(
        children: [
          Positioned(
            left: 8,
            right: 8,
            top: 14,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: SprintColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final d in marks)
                SizedBox(
                  width: 16,
                  child: OverflowBox(
                    maxWidth: 60,
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: [
                        const SizedBox(height: 4),
                        CustomPaint(
                          size: const Size(16, 16),
                          painter: _ConePainter(
                            d == 0
                                ? SprintColors.text
                                : d == workout.distanceM
                                ? SprintColors.lime
                                : SprintColors.orange,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          workout.targetTimeAt(d).toStringAsFixed(2),
                          style: SprintText.number(12),
                        ),
                        Text(
                          '$d m',
                          style: const TextStyle(
                            fontSize: 10,
                            color: SprintColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConePainter extends CustomPainter {
  const _ConePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ConePainter old) => old.color != color;
}

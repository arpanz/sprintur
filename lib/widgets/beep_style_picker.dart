import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../app/theme.dart';
import '../data/settings.dart';

/// One tile per beep style. Tapping a tile picks it and plays its go beep.
class BeepStylePicker extends ConsumerWidget {
  const BeepStylePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final BeepStyle value;
  final ValueChanged<BeepStyle> onChanged;

  static const _icons = {
    BeepStyle.classic: Icons.notifications_active_rounded,
    BeepStyle.whistle: Icons.sports_rounded,
    BeepStyle.low: Icons.graphic_eq_rounded,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        for (final (i, style) in BeepStyle.values.indexed) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: Semantics(
              button: true,
              selected: style == value,
              label: '${style.label} beep',
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onChanged(style);
                  ref.read(cuePlayerProvider).preview(style);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  height: 76,
                  decoration: BoxDecoration(
                    color: style == value
                        ? SprintColors.lime.withValues(alpha: 0.1)
                        : SprintColors.surface2,
                    border: Border.all(
                      color: style == value
                          ? SprintColors.lime
                          : SprintColors.border,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _icons[style],
                        size: 22,
                        color: style == value
                            ? SprintColors.lime
                            : SprintColors.textSoft,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        style.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: style == value
                              ? SprintColors.text
                              : SprintColors.textSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme.dart';

String formatRest(int seconds) =>
    '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

String formatDelta(double delta) =>
    '${delta <= 0 ? '−' : '+'}${delta.abs().toStringAsFixed(2)}';

/// The dark rounded card most content sits in.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: SprintColors.surface,
        border: Border.all(color: SprintColors.border),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}

/// Full-width pill button used for the main action on a screen.
class BigButton extends StatelessWidget {
  const BigButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.background = SprintColors.lime,
    this.foreground = SprintColors.bg,
    this.outlined = false,
    this.icon,
    this.height = 56,
    this.radius = 18,
    this.display = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color background;
  final Color foreground;
  final bool outlined;
  final IconData? icon;
  final double height;
  final double radius;

  /// Uppercase condensed label, for the session screen.
  final bool display;

  @override
  Widget build(BuildContext context) {
    final style = display
        ? SprintText.display(
            28,
            color: foreground,
          ).copyWith(letterSpacing: 1, height: 1)
        : TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: foreground,
          );
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Material(
        color: outlined ? Colors.transparent : background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: outlined
              ? const BorderSide(color: SprintColors.line, width: 2)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed == null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onPressed!();
                },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: foreground),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: style,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 44 px round icon button on a surface background.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 44,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: SprintColors.surface,
          foregroundColor: SprintColors.text,
        ),
        icon: Icon(icon, size: 20),
      ),
    );
  }
}

/// Small selectable chip, lime when selected.
class ChoiceChipButton extends StatelessWidget {
  const ChoiceChipButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minWidth: 44, minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? SprintColors.lime : Colors.transparent,
            border: Border.all(
              color: selected ? SprintColors.lime : SprintColors.line,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? SprintColors.bg : SprintColors.textSoft,
            ),
          ),
        ),
      ),
    );
  }
}

/// A pill-shaped on/off switch styled like the mockup.
class SprintSwitch extends StatelessWidget {
  const SprintSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: label,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onChanged(!value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          width: 52,
          height: 32,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: value ? SprintColors.lime : SprintColors.line,
            borderRadius: BorderRadius.circular(16),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: value ? SprintColors.bg : SprintColors.muted,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

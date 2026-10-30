import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class SprintColors {
  static const bg = Color(0xFF0B0C0E);
  static const surface = Color(0xFF16181C);
  static const surface2 = Color(0xFF1F2228);
  static const border = Color(0xFF23262C);
  static const line = Color(0xFF2A2E35);
  static const navBg = Color(0xFF0E0F12);
  static const setBg = Color(0xFF121408);

  static const text = Color(0xFFF2F3F5);
  static const textSoft = Color(0xFFB4BAC4);
  static const muted = Color(0xFF9AA1AC);

  static const lime = Color(0xFFD4FF3A);
  static const orange = Color(0xFFFF7A3D);
  static const orangeText = Color(0xFFFF9A68);
}

abstract final class SprintText {
  static const _display = 'BarlowCondensed';

  /// Big uppercase headings. Callers uppercase the string themselves.
  static TextStyle display(double size, {Color? color}) => TextStyle(
    fontFamily: _display,
    fontWeight: FontWeight.w800,
    fontSize: size,
    height: 0.92,
    letterSpacing: 0.3,
    color: color ?? SprintColors.text,
  );

  /// Times and counters: tabular figures so digits never jitter.
  static TextStyle number(double size, {Color? color}) => TextStyle(
    fontFamily: _display,
    fontWeight: FontWeight.w700,
    fontSize: size,
    height: 1,
    color: color ?? SprintColors.text,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static const label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.1,
    color: SprintColors.muted,
  );
}

ThemeData buildTheme() {
  final scheme = const ColorScheme.dark(
    primary: SprintColors.lime,
    onPrimary: SprintColors.bg,
    secondary: SprintColors.orange,
    surface: SprintColors.surface,
    onSurface: SprintColors.text,
    outline: SprintColors.line,
  );
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: SprintColors.bg,
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: const AppBarTheme(
      backgroundColor: SprintColors.bg,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: SprintColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: SprintColors.lime,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
  );
}

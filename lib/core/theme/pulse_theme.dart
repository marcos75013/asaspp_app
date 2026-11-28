import 'package:flutter/material.dart';

abstract final class PulseTheme {
  static const blue = Color(0xFF1267FF);
  static const purple = Color(0xFF853DFF);
  static const gradient = LinearGradient(colors: [blue, purple]);
  static const pagePadding = EdgeInsets.all(16);
  static const cardRadius = BorderRadius.all(Radius.circular(20));

  static LinearGradient headingGradient(Brightness brightness) =>
      brightness == Brightness.dark
      ? const LinearGradient(
          colors: [Color(0xFF5FE1CA), Color(0xFFA9C5FF), Color(0xFFC69BFF)],
        )
      : const LinearGradient(
          colors: [Color(0xFF00786B), Color(0xFF0053D6), Color(0xFF6934B6)],
        );

  static ThemeData build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(seedColor: blue, brightness: brightness)
        .copyWith(
          primary: Color(dark ? 0xFFA9C5FF : 0xFF0053D6),
          onPrimary: Color(dark ? 0xFF092554 : 0xFFFFFFFF),
          surface: Color(dark ? 0xFF192136 : 0xFFFFFFFF),
          onSurface: Color(dark ? 0xFFF5F7FF : 0xFF17213A),
          onSurfaceVariant: Color(dark ? 0xFFA6B3CC : 0xFF586681),
          outlineVariant: Color(dark ? 0xFF35415D : 0xFFE2E7F0),
        );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: Color(dark ? 0xFF0B1020 : 0xFFF5F7FC),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: cardRadius,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
    );
  }
}

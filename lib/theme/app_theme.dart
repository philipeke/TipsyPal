// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

/// Brand colors (tweak as you like)
const _seed = Color(0xFF6750A4);
const _bgDark = Color(0xFF0B0F17);

ThemeData buildLightTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.white,

    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      centerTitle: true,
    ),

    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      elevation: 2,
    ),

    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      isDense: true,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),

    // ⬇️ use CardThemeData (not CardTheme)
    cardTheme: CardThemeData(
      elevation: 0,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      side: BorderSide(color: scheme.outlineVariant),
    ),
  );
}

ThemeData buildDarkTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: Brightness.dark,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: _bgDark,

    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      centerTitle: true,
    ),

    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      elevation: 2,
    ),

    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      isDense: true,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),

    // ⬇️ use CardThemeData (not CardTheme)
    cardTheme: CardThemeData(
      color: scheme.surface,
      elevation: 0,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      side: BorderSide(color: scheme.outlineVariant),
    ),
  );
}

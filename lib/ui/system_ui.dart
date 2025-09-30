// lib/ui/system_ui.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Applies edge-to-edge and sets system UI (status/nav bar) to match theme.
void applySystemUi(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  // Content behind system bars
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Colors & icon brightness
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: theme.colorScheme.surface,
      systemNavigationBarIconBrightness: isDark
          ? Brightness.light
          : Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
}

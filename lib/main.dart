// lib/main.dart
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'ui/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TipsyPalApp());
}

class TipsyPalApp extends StatefulWidget {
  const TipsyPalApp({super.key});

  @override
  State<TipsyPalApp> createState() => _TipsyPalAppState();
}

class _TipsyPalAppState extends State<TipsyPalApp> {
  ThemeMode _mode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TipsyPal',
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: _mode,
      debugShowCheckedModeBanner: false,
      home: HomePage(
        themeMode: _mode,
        onToggleTheme: () {
          setState(() {
            _mode = _mode == ThemeMode.system
                ? ThemeMode.dark
                : _mode == ThemeMode.dark
                ? ThemeMode.light
                : ThemeMode.system;
          });
        },
      ),
    );
  }
}

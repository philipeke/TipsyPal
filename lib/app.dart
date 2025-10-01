import 'package:flutter/material.dart';
import 'features/chat/presentation/screens/category_screen.dart';

class TipsyPalApp extends StatelessWidget {
  const TipsyPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TipsyPal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const CategoryScreen(),
    );
  }
}

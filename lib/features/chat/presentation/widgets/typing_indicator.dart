import 'package:flutter/material.dart';

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key, required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    final dots = '.' * progress.floor();
    return Text(
      dots,
      style: const TextStyle(
        fontSize: 24,
        color: Colors.white38,
        letterSpacing: 3,
      ),
    );
  }
}

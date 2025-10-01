import 'package:flutter/material.dart';

IconData iconForCategory(String c) {
  switch (c) {
    case 'Humor':
      return Icons.emoji_emotions_outlined;
    case 'Ledsen':
      return Icons.mood_bad_outlined;
    case 'Filosofisk':
      return Icons.psychology_alt_outlined;
    case 'Smart':
      return Icons.lightbulb_outline;
    case 'Romantisk':
      return Icons.favorite_outline;
    case 'Random':
    default:
      return Icons.shuffle;
  }
}

Color colorForCategory(String c) {
  switch (c) {
    case 'Humor':
      return const Color(0xFF7DD3FC);
    case 'Ledsen':
      return const Color(0xFF60A5FA);
    case 'Filosofisk':
      return const Color(0xFFA78BFA);
    case 'Smart':
      return const Color(0xFFFBBF24);
    case 'Romantisk':
      return const Color(0xFFF472B6);
    case 'Random':
    default:
      return const Color(0xFF34D399);
  }
}

import 'dart:math';
import 'package:flutter/material.dart';

import '../../../chat/services/chat_service.dart';
import '../../../chat/presentation/screens/result_screen.dart';

// Enkel lokal snackbar-helper
void _snack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _chat = const ChatService();
  bool _loading = false;
  final _rand = Random();

  static const _categories = [
    _CatData('Humor', Icons.emoji_emotions_outlined),
    _CatData('Ledsen', Icons.mood_bad_outlined),
    _CatData('Filosofisk', Icons.psychology_alt_outlined),
    _CatData('Smart', Icons.lightbulb_outline),
    _CatData('Random', Icons.shuffle),
  ];

  static const Map<String, List<String>> _prompts = {
    'Humor': [
      'Skriv en kort, rolig svensk one-liner för sociala medier. Undvik svordomar.',
      'Ge mig en kvick, humoristisk uppdatering på svenska, max 25 ord.',
      'Skriv något ironiskt men vänligt som får folk att le. Svenska, max 30 ord.',
    ],
    'Ledsen': [
      'Formulera ett varmt, empatiskt inlägg om att känna sig nere – hoppfull ton, max 40 ord. Svenska.',
      'Skriv en kort text om sårbarhet och att det är okej att inte vara okej. Svenska.',
      'Hjälp mig säga att jag behöver en lugn dag och lite stöd, fint och respektfullt. Svenska.',
    ],
    'Filosofisk': [
      'Skriv en kort filosofisk reflektion om tid och val, poetisk men klar. Svenska.',
      'Ge mig en eftertänksam ministext om mening och närvaro, max 40 ord. Svenska.',
      'En liten tanke om balans mellan kontroll och släpp taget. Svenska.',
    ],
    'Smart': [
      'Skriv en smart, skarp observation om vardag och teknik, max 30 ord. Svenska.',
      'Ge mig ett fyndigt, intelligent take på produktivitet utan klyschor. Svenska.',
      'En kort “det här tänker ingen på”-reflektion, kvick men snäll. Svenska.',
    ],
    'Random': [
      'Överraska mig med ett oväntat, ofarligt inlägg som får folk att reagera positivt. Svenska.',
      'Skriv något lekfullt och kreativt som inte passar en låda. Svenska.',
      'Ge mig en kreativ mini-text med twist på slutet. Svenska.',
    ],
  };

  Future<void> _onTap(String category) async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      final variants = _prompts[category]!;
      final prompt = variants[_rand.nextInt(variants.length)];
      final text = await _chat.sendPrompt(prompt);

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            category: category,
            initialText: text,
            regenerate: () async {
              final p = variants[_rand.nextInt(variants.length)];
              return _chat.sendPrompt(p);
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _snack(context, e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TipsyPal'),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // LOGO (du skrev att den heter icon.png)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Image.asset(
                'assets/icon.png',
                height: 72,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.local_bar,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Välj stämning', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),

            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(16),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: _categories.map((c) {
                  return _CategoryTile(
                    label: c.label,
                    icon: c.icon,
                    loading: _loading,
                    onTap: () => _onTap(c.label),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatData {
  final String label;
  final IconData icon;
  const _CatData(this.label, this.icon);
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.loading,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36),
              const SizedBox(height: 8),
              Text(label, style: theme.textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}

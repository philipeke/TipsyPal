import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // För statusbar + haptics

import '../../../chat/services/chat_service.dart';
import '../../../chat/presentation/screens/result_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _rand = Random();
  bool _loading = false;
  String? _loadingLabel;

  // 👇 För press state-animation
  String? _pressedLabel;

  static const _categories = [
    _CatData('Humor', Icons.emoji_emotions_outlined),
    _CatData('Ledsen', Icons.mood_bad_outlined),
    _CatData('Filosofisk', Icons.psychology_alt_outlined),
    _CatData('Smart', Icons.lightbulb_outline),
    _CatData('Romantisk', Icons.favorite_outline),
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
    'Romantisk': [
      'Skriv ett kort, romantiskt meddelande på svenska som passar ett socialt inlägg.',
      'Formulera en varm och kärleksfull text som uttrycker känslor utan att bli överdriven. Svenska.',
      'Skriv ett romantiskt inlägg med poetisk ton, max 40 ord. Svenska.',
    ],
    'Random': [
      'Överraska mig med ett oväntat, ofarligt inlägg som får folk att reagera positivt. Svenska.',
      'Skriv något lekfullt och kreativt som inte passar en låda. Svenska.',
      'Ge mig en kreativ mini-text med twist på slutet. Svenska.',
    ],
  };

  Future<void> _onTap(String category) async {
    if (_loading) return;

    // 📳 Liten vibration när man trycker
    HapticFeedback.selectionClick();

    final prompts = () {
      if (category == 'Random') {
        const pool = ['Humor', 'Ledsen', 'Filosofisk', 'Smart', 'Romantisk'];
        final pick = pool[_rand.nextInt(pool.length)];
        return _prompts[pick]!;
      }
      return _prompts[category]!;
    }();

    final prompt = prompts[_rand.nextInt(prompts.length)];

    setState(() {
      _loading = true;
      _loadingLabel = category;
    });

    try {
      final text = await const ChatService().sendPrompt(prompt);
      if (!mounted) return;

      await Navigator.of(context).push(
        _fadeRoute(
          ResultScreen(
            category: category,
            response: text,
            onRegenerate: () async => const ChatService().sendPrompt(prompt),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Fel: $e')));
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadingLabel = null;
      });
    }
  }

  // ✨ Custom fade transition – 300ms mjuk övergång
  PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 🌚 Ljusare statusbar-ikoner över mörk bakgrund (konsekvent med ResultScreen)
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F17), // 🔒 solid mörk bakgrund
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // 🧠 Logo
            Image.asset('assets/icon.png', height: 120),
            const SizedBox(height: 16),
            Text(
              "TipsyPal",
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Booze can't spell 🍻",
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 32),

            // 📦 3×2 Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: _categories.map((c) {
                    final isLoadingTile = _loading && _loadingLabel == c.label;
                    final isPressed = _pressedLabel == c.label;

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (_) {
                        if (_loading) return;
                        setState(() => _pressedLabel = c.label);
                      },
                      onTapCancel: () {
                        if (_pressedLabel == c.label) {
                          setState(() => _pressedLabel = null);
                        }
                      },
                      onTapUp: (_) {
                        if (_pressedLabel == c.label) {
                          setState(() => _pressedLabel = null);
                        }
                      },
                      onTap: _loading ? null : () => _onTap(c.label),
                      child: AnimatedScale(
                        scale: isPressed ? 0.98 : 1.0,
                        duration: const Duration(milliseconds: 110),
                        curve: Curves.easeOut,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(
                                isLoadingTile ? 0.35 : 0.2,
                              ),
                              width: 1.2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(
                                    isLoadingTile
                                        ? 0.10
                                        : (isPressed ? 0.08 : 0.06),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    // Innehåll
                                    Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            c.icon,
                                            color: Colors.white,
                                            size: 38,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            c.label,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Spinner vid laddning
                                    if (isLoadingTile)
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: const Center(
                                            child: SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
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

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.category,
    required this.response,
    this.onRegenerate,
  });

  final String category;
  final String response;
  final Future<String> Function()? onRegenerate;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late String _text;
  String _displayText = '';
  bool _loading = false;
  bool _typing = false;
  bool _skipTyping = false;

  bool _altPressed = false;
  bool _regenPressed = false;

  late AnimationController _dotController;
  late Animation<double> _dotAnimation;

  @override
  void initState() {
    super.initState();
    _text = widget.response;

    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _dotAnimation = Tween<double>(
      begin: 0,
      end: 3,
    ).animate(CurvedAnimation(parent: _dotController, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_text.isNotEmpty) {
        await _typeInSlow(_text);
      }
    });
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  IconData _iconFor(String c) {
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

  Color _colorFor(String c) {
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

  static const Duration _slowPerChar = Duration(milliseconds: 28);

  Future<void> _typeInSlow(String newText) async {
    _skipTyping = false;
    _typing = true;
    setState(() => _displayText = '');

    final runes = newText.runes.toList();
    for (int i = 0; i < runes.length && mounted && !_skipTyping; i++) {
      _displayText += String.fromCharCode(runes[i]);
      setState(() {});
      await Future.delayed(_slowPerChar);
    }

    if (!mounted) return;
    setState(() {
      _displayText = newText;
      _typing = false;
    });
  }

  void _skipTypingNow() {
    if (_typing) _skipTyping = true;
  }

  Future<void> _onCopy() async {
    await HapticFeedback.selectionClick();
    await Clipboard.setData(ClipboardData(text: _text));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('📋 Kopierat till urklipp!')));
  }

  Future<void> _onShare() async {
    await HapticFeedback.selectionClick();
    if (_text.trim().isEmpty) return;
    final subject = 'TipsyPal – ${widget.category}';
    await Share.share(_text, subject: subject);
  }

  Future<void> _onRegenerate() async {
    if (widget.onRegenerate == null || _loading) return;

    setState(() => _loading = true);
    try {
      await HapticFeedback.selectionClick();
      final newText = await widget.onRegenerate!();
      if (!mounted) return;
      _text = newText;
      await _typeInSlow(newText);
    } catch (e) {
      if (!mounted) return;
      final retry = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1A1F2B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "❌ Kunde inte generera nytt svar",
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            "$e\n\nVill du försöka igen?",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Avbryt"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Försök igen"),
            ),
          ],
        ),
      );
      if (retry == true) await _onRegenerate();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openActionsSheet() async {
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1F2B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Vad vill du göra?",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigoAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.copy),
                        label: const Text("Kopiera"),
                        onPressed: () async {
                          Navigator.pop(context);
                          await _onCopy();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.share),
                        label: const Text("Dela"),
                        onPressed: () async {
                          Navigator.pop(context);
                          await _onShare();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Stäng",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return AnimatedBuilder(
      animation: _dotAnimation,
      builder: (_, __) {
        final dots = '.' * _dotAnimation.value.floor();
        return Text(
          dots,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white38,
            letterSpacing: 3,
          ),
        );
      },
    );
  }

  Widget _buildCategoryBadge() {
    final color = _colorFor(widget.category);
    final icon = _iconFor(widget.category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            widget.category,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLengthHint() {
    final words = _text.trim().isEmpty
        ? 0
        : _text.trim().split(RegExp(r'\s+')).length;
    return Text(
      "$words ord",
      style: const TextStyle(color: Colors.white38, fontSize: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F17),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Tillbaka',
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () async {
            await HapticFeedback.lightImpact();
            if (!mounted) return;
            // 🪄 Liten fade-animation innan pop
            await Future.delayed(const Duration(milliseconds: 80));
            if (mounted) Navigator.of(context).pop();
          },
        ),

        title: Row(
          children: [
            _buildCategoryBadge(),
            const SizedBox(width: 12),
            _buildLengthHint(),
          ],
        ),
        actions: [
          IconButton(onPressed: _onCopy, icon: const Icon(Icons.copy)),
          IconButton(onPressed: _onShare, icon: const Icon(Icons.share)),
          if (widget.onRegenerate != null)
            IconButton(
              tooltip: 'Generera nytt',
              onPressed: _loading ? null : _onRegenerate,
              icon: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: GestureDetector(
            onTap: _skipTypingNow,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.035),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.10)),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          _displayText.isEmpty
                              ? '🤖 Inget svar från GPT…'
                              : _displayText,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 20,
                            height: 1.6,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_typing) _buildTypingIndicator(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Row(
          children: [
            Expanded(
              child: Listener(
                onPointerDown: (_) => setState(() => _altPressed = true),
                onPointerUp: (_) => setState(() => _altPressed = false),
                onPointerCancel: (_) => setState(() => _altPressed = false),
                child: AnimatedScale(
                  scale: _altPressed ? 0.98 : 1.0,
                  duration: const Duration(milliseconds: 110),
                  curve: Curves.easeOut,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await HapticFeedback.selectionClick();
                      _openActionsSheet();
                    },
                    icon: const Icon(Icons.more_horiz),
                    label: const Text('Alternativ'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (widget.onRegenerate != null)
              Expanded(
                child: Listener(
                  onPointerDown: (_) {
                    if (_loading) return;
                    setState(() => _regenPressed = true);
                  },
                  onPointerUp: (_) => setState(() => _regenPressed = false),
                  onPointerCancel: (_) => setState(() => _regenPressed = false),
                  child: AnimatedScale(
                    scale: (_regenPressed && !_loading) ? 0.98 : 1.0,
                    duration: const Duration(milliseconds: 110),
                    curve: Curves.easeOut,
                    child: FilledButton.icon(
                      onPressed: _loading ? null : _onRegenerate,
                      icon: _loading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                      label: Text(_loading ? 'Genererar…' : 'Nytt'),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

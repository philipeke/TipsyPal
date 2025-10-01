import 'dart:ui';
import 'package:flutter/material.dart';

class ResultTextBox extends StatefulWidget {
  const ResultTextBox({
    super.key,
    required this.text,
    this.perChar = const Duration(milliseconds: 28),
  });

  final String text;
  final Duration perChar;

  @override
  State<ResultTextBox> createState() => _ResultTextBoxState();
}

class _ResultTextBoxState extends State<ResultTextBox>
    with SingleTickerProviderStateMixin {
  String _displayText = '';
  bool _typing = false;
  bool _skipTyping = false;

  late final AnimationController _dots;
  late final Animation<double> _dotAnim;

  @override
  void initState() {
    super.initState();
    _dots = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _dotAnim = Tween<double>(
      begin: 0,
      end: 3,
    ).animate(CurvedAnimation(parent: _dots, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animateIn(widget.text);
    });
  }

  @override
  void didUpdateWidget(covariant ResultTextBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _animateIn(widget.text);
    }
  }

  @override
  void dispose() {
    _dots.dispose();
    super.dispose();
  }

  Future<void> _animateIn(String full) async {
    _skipTyping = false;
    _typing = true;
    setState(() => _displayText = '');

    final runes = full.runes.toList();
    for (int i = 0; i < runes.length && mounted && !_skipTyping; i++) {
      _displayText += String.fromCharCode(runes[i]);
      setState(() {});
      await Future.delayed(widget.perChar);
    }

    if (!mounted) return;
    setState(() {
      _displayText = full;
      _typing = false;
    });
  }

  void _skip() {
    if (_typing) _skipTyping = true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _skip,
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
                  if (_typing)
                    AnimatedBuilder(
                      animation: _dotAnim,
                      builder: (_, __) {
                        final dots = '.' * _dotAnim.value.floor();
                        return Text(
                          dots,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white38,
                            letterSpacing: 3,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

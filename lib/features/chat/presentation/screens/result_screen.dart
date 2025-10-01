import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../widgets/result_app_bar.dart';
import '../widgets/result_text_box.dart';
import '../widgets/result_bottom_bar.dart';
import '../widgets/actions_sheet.dart';

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

class _ResultScreenState extends State<ResultScreen> {
  late String _text;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _text = widget.response;
  }

  int get _wordCount =>
      _text.trim().isEmpty ? 0 : _text.trim().split(RegExp(r'\s+')).length;

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
      // Uppdatera texten – ResultTextBox fångar detta i didUpdateWidget och animerar in
      setState(() => _text = newText);
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

  Future<void> _openActions() async {
    await showActionsSheet(
      context: context,
      onCopy: _onCopy,
      onShare: _onShare,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ljus statusbar över mörk bakgrund
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F17),
      appBar: ResultAppBar(
        category: widget.category,
        wordCount: _wordCount,
        onBack: () => Navigator.of(context).pop(),
        onCopy: _onCopy,
        onShare: _onShare,
        onRegenerate: widget.onRegenerate != null ? _onRegenerate : null,
        isLoading: _loading,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ResultTextBox(
            text: _text,
            // perChar kan tweakas här om du vill (default 28 ms/tecken)
            // perChar: const Duration(milliseconds: 28),
          ),
        ),
      ),
      bottomNavigationBar: ResultBottomBar(
        onOpenActions: _openActions,
        onRegenerate: widget.onRegenerate != null ? _onRegenerate : null,
        loading: _loading,
      ),
    );
  }
}

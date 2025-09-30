import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.category,
    required this.initialText,
    required this.regenerate,
  });

  final String category;
  final String initialText;
  final Future<String> Function() regenerate;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late String _text;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _text = widget.initialText;
  }

  Future<void> _onCopy() async {
    await Clipboard.setData(ClipboardData(text: _text));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Kopierat ✅')));
  }

  Future<void> _onRegenerate() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final t = await widget.regenerate();
      if (!mounted) return;
      setState(() => _text = t);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
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
        title: Text(widget.category),
        backgroundColor: theme.colorScheme.primaryContainer,
        actions: [
          IconButton(
            tooltip: 'Kopiera',
            onPressed: _onCopy,
            icon: const Icon(Icons.copy),
          ),
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
          padding: const EdgeInsets.all(16),
          child: SelectableText(
            _text.isEmpty ? 'Inget svar…' : _text,
            style: theme.textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}

// lib/ui/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api/tipsypal_api.dart';
import 'system_ui.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _api = TipsyPalApi();

  String _response = '';
  bool _loading = false;
  String _currentTone = 'Funny';

  // Tone presets instruct the model to write in a safe, short, specific style.
  static const Map<String, String> _tonePresets = {
    'Funny':
        'Write a short, witty, and sober-sounding caption. Keep it tasteful and typo-free.',
    'Sincere':
        'Write a short, sincere, supportive caption in a friendly tone. No slang, no typos.',
    'Philosophical':
        'Write a short, reflective one-liner with a thoughtful vibe. Keep it clean.',
    'Melancholic':
        'Write a short, gentle caption with subtle melancholy (no negativity or self-harm).',
  };

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    _api.close();
    super.dispose();
  }

  // Keep Android system UI (status/nav bars) in sync with theme.
  void _applyUi() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) applySystemUi(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _applyUi(); // after first layout (Theme is available)
  }

  String _composePrompt(String userInput) {
    final tone = _tonePresets[_currentTone]!;
    return '$tone\nUser intent: ${userInput.trim()}';
  }

  Future<void> _sendPrompt([String? override]) async {
    final text = (override ?? _input.text).trim();
    if (text.isEmpty) {
      _showSnack('Skriv något först ✍️');
      return;
    }

    setState(() {
      _loading = true;
      _response = '';
    });

    try {
      final result = await _api.complete(prompt: _composePrompt(text));
      setState(
        () => _response = result.trim().isEmpty
            ? '— (tomt svar) —'
            : result.trim(),
      );
    } on TipsyPalApiError catch (e) {
      _showSnack(e.message);
    } catch (e) {
      _showSnack('Nätverksfel: $e');
    } finally {
      setState(() => _loading = false);
      await Future.delayed(const Duration(milliseconds: 120));
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
      _applyUi(); // keep system UI in sync after state changes
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    // Keep system UI updated on each rebuild (e.g., after theme toggle)
    _applyUi();

    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TipsyPal'),
        // Smooth status bar icon color during transitions
        systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            icon: Icon(
              widget.themeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : widget.themeMode == ThemeMode.light
                  ? Icons.light_mode
                  : Icons.brightness_auto,
            ),
            onPressed: widget.onToggleTheme,
          ),
          IconButton(
            tooltip: 'Copy response',
            icon: const Icon(Icons.copy_all),
            onPressed: _response.trim().isEmpty
                ? null
                : () async {
                    await Clipboard.setData(ClipboardData(text: _response));
                    _showSnack('Kopierat ✅');
                  },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tone chips row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _tonePresets.keys.map((tone) {
                    final selected = tone == _currentTone;
                    return ChoiceChip(
                      label: Text(tone),
                      selected: selected,
                      onSelected: (v) => setState(() => _currentTone = tone),
                      selectedColor: scheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: selected
                            ? scheme.onPrimaryContainer
                            : scheme.onSurface,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Prompt input + send
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendPrompt(),
                      decoration: InputDecoration(
                        hintText: 'Skriv din prompt…',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _loading ? null : _sendPrompt,
                    icon: _loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    label: Text(_loading ? 'Skickar…' : 'Skicka'),
                  ),
                ],
              ),
            ),

            // Response card
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  controller: _scroll,
                  child: SelectableText(
                    _response.isEmpty
                        ? '🧠 Svar från GPT visas här…'
                        : _response,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ),

            // Footer: backend indicator + clear
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      // kBackendUrl comes from api file
                      'Backend: $kBackendUrl',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: scheme.outline),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _loading
                        ? null
                        : () {
                            setState(() {
                              _input.clear();
                              _response = '';
                            });
                          },
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Rensa'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

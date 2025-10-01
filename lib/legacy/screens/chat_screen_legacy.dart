import 'package:flutter/material.dart';
import 'package:tipsypal/core/utils/snack.dart';
import '../../../../legacy/widgets/preset_buttons.dart';
import '../../../../legacy/widgets/prompt_input.dart';
import '../../../../legacy/widgets/response_box.dart';
import 'package:tipsypal/features/chat/services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final ChatService _chat = const ChatService();

  String _response = '';
  bool _loading = false;

  final List<String> _presetPrompts = const [
    "Ge mig ett snabbt tips för en vardagsmiddag.",
    "Säg ett peppigt citat för dagen.",
    "Föreslå en enkel träningsrutin på 10 minuter.",
  ];

  Future<void> _sendPrompt(String prompt) async {
    if (prompt.trim().isEmpty) {
      if (!mounted) return;
      showSnack(context, "Skriv något först ✍️");
      return;
    }

    setState(() {
      _loading = true;
      _response = '';
    });

    try {
      final text = await _chat.sendPrompt(prompt);
      if (!mounted) return;
      setState(() => _response = text);
    } catch (e) {
      if (!mounted) return;
      showSnack(context, e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);

      await Future.delayed(const Duration(milliseconds: 100));
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("TipsyPal"),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Preset-knappar
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: PresetButtons(
                presets: _presetPrompts,
                loading: _loading,
                onTap: (p) => _sendPrompt(p),
              ),
            ),

            // Input + Skicka
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: PromptInput(
                controller: _input,
                loading: _loading,
                onSubmit: (v) => _sendPrompt(v),
                onSend: () => _sendPrompt(_input.text),
              ),
            ),

            // Svar
            Expanded(
              child: ResponseBox(controller: _scroll, response: _response),
            ),
          ],
        ),
      ),
    );
  }
}

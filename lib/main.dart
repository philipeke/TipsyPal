// lib/main.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// BYT UT Project ID i URL:en nedan till ditt riktiga (utan <>).
/// Exempel: tipsypal-eeb0b eller tipsypal-app (om du skapade nytt).
const String backendUrl =
    "https://europe-north1-tipsypal-app.cloudfunctions.net/chat";
//  Exempel om du använder det andra projektet:
// const String backendUrl =
//     "https://europe-north1-tipsypal-eeb0b.cloudfunctions.net/chat";

void main() {
  runApp(const TipsyPalApp());
}

class TipsyPalApp extends StatelessWidget {
  const TipsyPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TipsyPal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();

  String _response = '';
  bool _loading = false;

  final List<String> _presetPrompts = const [
    "Ge mig ett snabbt tips för en vardagsmiddag.",
    "Säg ett peppigt citat för dagen.",
    "Föreslå en enkel träningsrutin på 10 minuter.",
  ];

  Future<void> _sendPrompt(String prompt) async {
    if (prompt.trim().isEmpty) {
      _showSnack("Skriv något först ✍️");
      return;
    }
    setState(() {
      _loading = true;
      _response = '';
    });

    try {
      final res = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"prompt": prompt}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        setState(() {
          _response = (data["text"] ?? "").toString();
        });
      } else if (res.statusCode == 429) {
        // 🔴 Hantering av kvot-slut / rate limit
        _showSnack(
          "⚠️ OpenAI-kvoten är slut eller du är rate-limited.\n"
          "Kolla din OpenAI-plan i dashboarden.",
        );
      } else {
        // generellt fel från server
        final body = res.body.toString();
        _showSnack(
          "Fel ${res.statusCode}: ${body.isEmpty ? 'Okänt fel' : body}",
        );
      }
    } catch (e) {
      _showSnack("Nätverksfel: $e");
    } finally {
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

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presetPrompts.map((p) {
                  return ElevatedButton(
                    onPressed: _loading ? null : () => _sendPrompt(p),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      p.length > 28 ? "${p.substring(0, 28)}…" : p,
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList(),
              ),
            ),

            // Input + Skicka
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Skriv din prompt…",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (v) => _sendPrompt(v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _loading ? null : () => _sendPrompt(_input.text),
                    icon: _loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    label: Text(_loading ? "Skickar…" : "Skicka"),
                  ),
                ],
              ),
            ),

            // Svar
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                    0.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  controller: _scroll,
                  child: SelectableText(
                    _response.isEmpty
                        ? "🧠 Svar från GPT visas här…"
                        : _response,
                    style: theme.textTheme.bodyLarge,
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

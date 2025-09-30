import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tipsypal/core/config/env.dart';

class ChatService {
  const ChatService();

  /// Returnerar GPT-textsvar, eller kastar [ChatException] vid fel.
  Future<String> sendPrompt(String prompt) async {
    final uri = Uri.parse(Env.backendUrl);
    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"prompt": prompt}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return (data["text"] ?? "").toString();
    }

    if (res.statusCode == 429) {
      throw const ChatException(
        "⚠️ OpenAI-kvoten är slut eller du är rate-limited.\n"
        "Kolla din OpenAI-plan i dashboarden.",
      );
    }

    final body = res.body.toString();
    throw ChatException(
      "Fel ${res.statusCode}: ${body.isEmpty ? 'Okänt fel' : body}",
    );
  }
}

class ChatException implements Exception {
  final String message;
  const ChatException(this.message);
  @override
  String toString() => message;
}

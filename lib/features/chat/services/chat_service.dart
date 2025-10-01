import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

/// ChatService ansvarar för att skicka promptar till backend och hämta GPT-svar.
/// Den pratar endast med din Cloud Function och exponerar ett rent API till resten av appen.
class ChatService {
  /// Din backend-URL – byt om du deployar till ny miljö.
  static const String backendUrl =
      "https://europe-north1-tipsypal-app.cloudfunctions.net/chat";

  const ChatService();

  /// Skickar en [prompt] till backend och returnerar GPT-svaret som en [String].
  ///
  /// 🔁 Försöker upp till [maxRetries] gånger vid nätverksfel eller timeout.
  /// 📢 Om [onRetry] anges kallas den varje gång ett nytt försök görs.
  Future<String> sendPrompt(
    String prompt, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
    void Function(int attempt, Duration delay)? onRetry,
  }) async {
    int attempt = 0;
    late Object lastError;

    while (attempt < maxRetries) {
      attempt++;
      try {
        final uri = Uri.parse(backendUrl);

        final res = await http
            .post(
              uri,
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({"prompt": prompt}),
            )
            .timeout(const Duration(seconds: 20)); // ⏱️ Timeout-skydd

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final text = (data["text"] ?? "").toString();
          if (text.trim().isEmpty) {
            throw const ChatException(
              "✅ Anrop lyckades men inget svar returnerades.",
            );
          }
          return text;
        }

        if (res.statusCode == 429) {
          throw const ChatException(
            "⚠️ OpenAI-kvoten är slut eller du är rate-limited.\n"
            "Kontrollera din OpenAI-plan i dashboarden.",
          );
        }

        throw ChatException(
          "❌ Fel ${res.statusCode}: ${res.body.isNotEmpty ? res.body : 'Okänt fel från servern.'}",
        );
      } on SocketException catch (e) {
        lastError = e;
        if (attempt < maxRetries) {
          final delay = retryDelay * attempt;
          onRetry?.call(attempt, delay);
          await Future.delayed(delay);
          continue;
        }
        throw const ChatException("📶 Nätverksfel: Ingen internetanslutning.");
      } on TimeoutException catch (e) {
        lastError = e;
        if (attempt < maxRetries) {
          final delay = retryDelay * attempt;
          onRetry?.call(attempt, delay);
          await Future.delayed(delay);
          continue;
        }
        throw const ChatException("⏱️ Timeout – servern svarade inte i tid.");
      } on FormatException {
        throw const ChatException(
          "📡 Felaktigt svar från servern – JSON kunde inte tolkas.",
        );
      } on HttpException {
        throw const ChatException("🌐 HTTP-fel – kontrollera backend-status.");
      } catch (e) {
        lastError = e;
        throw ChatException("❌ Okänt fel: $e");
      }
    }

    throw ChatException("❌ Misslyckades efter $maxRetries försök: $lastError");
  }
}

/// En strukturerad felklass för GPT-kommunikation.
class ChatException implements Exception {
  final String message;
  const ChatException(this.message);
  @override
  String toString() => message;
}

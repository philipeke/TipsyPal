// lib/api/tipsypal_api.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Reads BACKEND_URL from --dart-define. Falls back to production URL.
const String kBackendUrl = String.fromEnvironment(
  'BACKEND_URL',
  defaultValue: 'https://europe-north1-tipsypal-app.cloudfunctions.net/chat',
);

class TipsyPalApi {
  TipsyPalApi({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  /// Sends the prompt to backend and returns the AI text response.
  Future<String> complete({
    required String prompt,
    int maxTokens = 240,
    int retries = 1,
  }) async {
    if (prompt.trim().isEmpty) {
      throw const TipsyPalApiError('Prompt cannot be empty', code: 'empty');
    }

    Object? lastError;

    for (var attempt = 0; attempt <= retries; attempt++) {
      try {
        final resp = await _client.post(
          Uri.parse(kBackendUrl),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: jsonEncode({'prompt': prompt, 'max_tokens': maxTokens}),
        );

        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body) as Map<String, dynamic>;
          final text = (data['text'] ?? data['message'] ?? '').toString();
          return text;
        }

        if (resp.statusCode == 429) {
          throw const TipsyPalApiError(
            'Rate limited or quota exceeded. Try again shortly.',
            code: 'rate_limited',
          );
        }
        if (resp.statusCode == 400) {
          throw const TipsyPalApiError(
            'Bad request. Please update the app.',
            code: 'bad_request',
          );
        }
        if (resp.statusCode == 401 || resp.statusCode == 403) {
          throw const TipsyPalApiError(
            'Unauthorized. Contact support.',
            code: 'auth',
          );
        }

        throw TipsyPalApiError(
          'Server error (${resp.statusCode}).',
          code: 'server_${resp.statusCode}',
        );
      } catch (e) {
        lastError = e;
        if (attempt < retries) {
          // simple exponential backoff
          await Future.delayed(Duration(milliseconds: 400 * (1 << attempt)));
          continue;
        }
        // out of retries -> break loop and throw below
        break;
      }
    }

    throw TipsyPalApiError('Network/Server error: $lastError', code: 'network');
  }

  void close() => _client.close();
}

class TipsyPalApiError implements Exception {
  final String message;
  final String code;
  const TipsyPalApiError(this.message, {this.code = 'unknown'});
  @override
  String toString() => 'TipsyPalApiError($code): $message';
}

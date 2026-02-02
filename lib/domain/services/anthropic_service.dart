import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../data/datasources/local/secure_storage_datasource.dart';
import '../../data/models/ai_suggestion.dart';

class AnthropicApiException implements Exception {
  final String message;
  final int? statusCode;

  AnthropicApiException(this.message, {this.statusCode});

  @override
  String toString() => 'AnthropicApiException: $message (status: $statusCode)';
}

class AnthropicService {
  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-haiku-4-5-20251001';
  static const Duration _timeout = Duration(seconds: 30);

  final SecureStorageDatasource _secureStorage;
  final http.Client _httpClient;

  AnthropicService({
    required SecureStorageDatasource secureStorage,
    http.Client? httpClient,
  })  : _secureStorage = secureStorage,
        _httpClient = httpClient ?? http.Client();

  Future<List<AISuggestion>> getStemSuggestions({
    required String completion,
    required String stemText,
    int count = 5,
  }) async {
    final apiKey = await _secureStorage.getAnthropicApiKey();
    if (apiKey == null || apiKey.trim().isEmpty) {
      throw AnthropicApiException('No API key configured');
    }
    final trimmedKey = apiKey.trim();

    final prompt = _buildPrompt(completion, stemText, count);

    try {
      final response = await _httpClient
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'x-api-key': trimmedKey,
              'anthropic-version': '2023-06-01',
            },
            body: jsonEncode({
              'model': _model,
              'max_tokens': 1024,
              'messages': [
                {
                  'role': 'user',
                  'content': prompt,
                }
              ],
            }),
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['error']?['message'] ?? 'Unknown error';
        throw AnthropicApiException(
          errorMessage,
          statusCode: response.statusCode,
        );
      }

      final responseBody = jsonDecode(response.body);
      final content = responseBody['content'] as List<dynamic>;
      if (content.isEmpty) {
        throw AnthropicApiException('Empty response from API');
      }

      final textContent = content.first['text'] as String;
      return _parseSuggestions(textContent, count);
    } on TimeoutException {
      throw AnthropicApiException('Request timed out');
    } on FormatException catch (e) {
      throw AnthropicApiException('Failed to parse response: $e');
    }
  }

  Future<({bool valid, String? error})> validateApiKey(String apiKey) async {
    final trimmedKey = apiKey.trim();
    if (trimmedKey.isEmpty) {
      return (valid: false, error: 'API key is empty');
    }

    try {
      final response = await _httpClient
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'x-api-key': trimmedKey,
              'anthropic-version': '2023-06-01',
            },
            body: jsonEncode({
              'model': _model,
              'max_tokens': 10,
              'messages': [
                {
                  'role': 'user',
                  'content': 'Say "ok"',
                }
              ],
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return (valid: true, error: null);
      }

      // Parse error message from response
      try {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['error']?['message'] ?? 'Unknown error';
        return (valid: false, error: '$errorMessage (${response.statusCode})');
      } catch (_) {
        return (valid: false, error: 'HTTP ${response.statusCode}');
      }
    } on TimeoutException {
      return (valid: false, error: 'Connection timed out');
    } catch (e) {
      return (valid: false, error: e.toString());
    }
  }

  String _buildPrompt(String completion, String stemText, int count) {
    return '''You are helping with a sentence completion journaling app. The user just completed the following sentence stem:

Stem: "$stemText"
User's completion: "$completion"

Generate exactly $count follow-up SENTENCE STEMS for continued self-reflection.

CRITICAL RULES:
- Each stem must be an INCOMPLETE sentence that the user will finish
- Each stem must END with "..." (trailing off, inviting completion)
- NEVER write questions (no question marks)
- NEVER write complete sentences
- Start with phrases like: "I feel...", "When I...", "The thing I...", "What I really want is...", "If I could...", "The part of me that..."

SPECIFICITY RULES (VERY IMPORTANT):
- Each stem must be SELF-CONTAINED and meaningful on its own
- NEVER use vague references like "this belief", "this feeling", "that situation", "this person" - these are meaningless without context
- Instead, INCLUDE the specific topic/theme from the user's completion in the stem itself
- Replace names with relationship terms: "Gabe" → "my son", "Sarah" → "my partner", etc.
- The user will see these stems days or weeks later - they must make sense without remembering the original entry

GOOD examples (specific and self-contained):
- "When I think about wanting more independence, I notice..."
- "The fear underneath my worry about finances is..."
- "What I haven't admitted about my relationship with my mother is..."

BAD examples (DO NOT DO):
- "The truth I'm avoiding about this belief is..." (vague - what belief?)
- "When I think about that situation, I feel..." (vague - what situation?)
- "This feeling comes from..." (vague - what feeling?)
- "What would you say to yourself?" (question - wrong)
- "I feel happy." (complete sentence - wrong)
- "When I think about Gabe, I..." (uses specific name - wrong)

Format as a numbered list with just the stem text:
1. [incomplete sentence ending with ...]
2. [incomplete sentence ending with ...]''';
  }

  List<AISuggestion> _parseSuggestions(String text, int count) {
    final lines = text.split('\n');
    final suggestions = <AISuggestion>[];

    final stemRegex = RegExp(r'^\d+\.\s*(.+)$');

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      final match = stemRegex.firstMatch(trimmed);
      if (match != null) {
        var stemText = match.group(1)!.trim();
        // Remove surrounding quotes if present
        if ((stemText.startsWith('"') && stemText.endsWith('"')) ||
            (stemText.startsWith("'") && stemText.endsWith("'"))) {
          stemText = stemText.substring(1, stemText.length - 1);
        }
        suggestions.add(AISuggestion.create(stemText));
      }

      if (suggestions.length >= count) break;
    }

    return suggestions;
  }
}

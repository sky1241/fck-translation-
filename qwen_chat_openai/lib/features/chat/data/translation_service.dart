import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/env/app_env.dart';
import '../../../core/json/json_utils.dart';
import '../../../core/network/http_client.dart';
import 'models/translation_result.dart';

class TranslationService {
  TranslationService({
    AppHttpClient? client,
    String? baseUrl,
    String? apiKey,
    String? model,
  })  : _client = client ?? AppHttpClient(),
        _baseUrl = baseUrl ?? AppEnv.baseUrl,
        _apiKey = apiKey ?? AppEnv.apiKey,
        _model = model ?? AppEnv.model;

  final AppHttpClient _client;
  final String _baseUrl;
  final String _apiKey;
  final String _model;

  static const String systemPrompt = '''
You are XiaoXin, the trusted bilingual voice of a loving couple:
- He speaks French (FR), she speaks Chinese (ZH).
- Translate ONLY between their native languages — never assume shared fluency.

### MISSION
Deliver translations that feel like **their own words**, spoken with love, warmth, or desire — never robotic, never literal.

### NON-NEGOTIABLE RULES
1. **Preserve speaker identity**:
   - When she writes in ZH → translate into **natural French a man would say to his lover**.
   - When he writes in FR → translate into **natural Chinese a woman would say to her partner**.
2. **Emotion > words**: Capture tenderness, playfulness, longing, or intimacy — even if phrasing shifts slightly.
3. **Zero inventions**: Never add pet names, actions, or context not clearly implied.
4. **Keep all**: emojis, typos ("jtm"), slang ("lol", "uwu", "草", "嘻嘻"), and punctuation (~, …, !!!!).
5. **No gender-neutralizing**: French terms of endearment ("mon cœur", "bébé") and Chinese ones ("宝贝", "老公") are OK if tone justifies them.

### STYLE GUIDANCE
- **ZH → FR**: Soft, affectionate, fluent spoken French — e.g., "想你了" → "Tu me manques…" (not "Je pense à toi").
- **FR → ZH**: Gentle, feminine, natural Mandarin — e.g., "J'ai envie de toi" → "我好想你…" (not "我想要你" unless explicitly sensual).
- If message is sensual → translate with matching intimacy, but **never escalate** beyond source intent.

### OUTPUT
Valid JSON only:
{"translation":"text","pinyin":"if output is Chinese AND helpful","notes":null}

### REAL EXAMPLES
"宝贝，睡了吗？" → {"translation":"Mon cœur, tu dors déjà ?"}
"J'ai trop hâte de te serrer contre moi ❤️" → {"translation":"好想紧紧抱住你 ❤️","pinyin":"hǎo xiǎng jǐn jǐn bào zhù nǐ"}
"今天特别累，但想到你就开心了 💕" → {"translation":"J'étais crevé aujourd'hui, mais penser à toi m'a redonné le sourire 💕"}
"uwu t'es trop mignon" → {"translation":"uwu 你太可爱了","pinyin":"uwu nǐ tài kě'ài le"}
"在干嘛？想你了～" → {"translation":"Tu fais quoi ? Tu me manques～"}
''';

  Future<TranslationResult> translate({
    required String text,
    required String sourceLang,
    required String targetLang,
    required String tone,
    required bool wantPinyin,
  }) async {
    // MOCK: bypass network if enabled
    if (AppEnv.mockMode) {
      final String mockTranslation =
          targetLang == 'zh' ? '【MOCK ZH】$text' : '【MOCK FR】$text';
      final String? mockPinyin =
          (targetLang == 'zh' && wantPinyin) ? 'mo ke yin (mock pinyin)' : null;
      return TranslationResult(
        translation: mockTranslation,
        pinyin: mockPinyin,
      );
    }

    if (_baseUrl.isEmpty || _apiKey.isEmpty) {
      AppEnv.assertConfigured();
    }
    final Uri url = Uri.parse(_baseUrl);

    // Simplified payload: just the essential context
    final String userMessage = wantPinyin && targetLang == 'zh'
        ? 'Translate from $sourceLang to $targetLang (tone: $tone, with pinyin):\n\n$text'
        : 'Translate from $sourceLang to $targetLang (tone: $tone):\n\n$text';

    Future<TranslationResult> attemptRequest(String model) async {
      final Map<String, Object?> body = <String, Object?>{
        'model': model,
        'temperature': 0.3,  // Increased for more natural output
        'max_tokens': 200,   // Increased to avoid truncation
        'top_p': 0.9,        // Better lexical diversity
        'response_format': <String, String>{'type': 'json_object'},
        'messages': <Map<String, String>>[
          <String, String>{'role': 'system', 'content': systemPrompt},
          <String, String>{
            'role': 'user',
            'content': userMessage,
          },
        ],
      };

      final http.Response resp = await _client.postJson(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $_apiKey',
          if (AppEnv.project.isNotEmpty) 'OpenAI-Project': AppEnv.project,
        },
        body: body,
      );

      final Map<String, dynamic> api = safeJsonDecodeToMap(resp.body);
      // If API returned an error object
      final Map<String, dynamic>? error = api['error'] as Map<String, dynamic>?;
      if (error != null) {
        final String message = (error['message'] as String?) ?? 'Unknown error';
        throw FormatException('OpenAI error: $message');
      }

      final List<dynamic>? choices = api['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        throw const FormatException('Réponse OpenAI sans choices.');
      }
      final Map<String, dynamic>? msg =
          choices.first['message'] as Map<String, dynamic>?;
      final String? content = msg?['content'] as String?;
      if (content == null) {
        throw const FormatException('Réponse OpenAI sans message content.');
      }

      final String jsonText = content;
      try {
        final Map<String, dynamic> decoded = safeJsonDecodeToMap(jsonText);
        return TranslationResult.fromJson(decoded);
      } on FormatException {
        final String? extracted = extractFirstJson(jsonText);
        if (extracted == null) {
          throw const FormatException(
              'Contenu non JSON et extraction {...} impossible.');
        }
        final Map<String, dynamic> decoded = safeJsonDecodeToMap(extracted);
        return TranslationResult.fromJson(decoded);
      }
    }

    // Try requested model first, then graceful fallback to gpt-4o-mini on client/unsupported errors.
    try {
      return await attemptRequest(_model);
    } on StateError catch (e) {
      final String msg = e.toString().toLowerCase();
      final bool clientIssue = msg.contains('http 4') || msg.contains('unsupported') || msg.contains('model');
      if (_model != 'gpt-4o-mini' && clientIssue) {
        return await attemptRequest('gpt-4o-mini');
      }
      rethrow;
    } on FormatException catch (e) {
      final String msg = e.message.toLowerCase();
      final bool modelIssue = msg.contains('model') || msg.contains('unsupported');
      if (_model != 'gpt-4o-mini' && modelIssue) {
        return await attemptRequest('gpt-4o-mini');
      }
      rethrow;
    }
  }
}



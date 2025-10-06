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

  static const String systemPrompt =
      'You are a realtime dialogue translator for FR↔ZH ONLY (French ⇄ Chinese Simplified).\n'
      'Never use or output any other language.\n'
      'CRITICAL RULES:\n'
      '1) Translate faithfully, but make target text idiomatic and natural for casual messaging (WeChat/WhatsApp).\n'
      '2) Apply requested TONE (casual/affectionate/business).\n'
      '3) Preserve emojis; avoid vulgarity unless explicitly present.\n'
      '4) TARGET=Chinese: use Simplified Chinese (zh-Hans). If French is blunt, mitigate politely (委婉) while preserving intent. Provide pinyin ONLY if requested.\n'
      '5) TARGET=French: idiomatic, concise, emotionally clear; default tutoiement in romance, vouvoiement in business unless stated otherwise.\n'
      '6) Do NOT add facts or change intent; no safety boilerplate; no Markdown.\n'
      '7) OUTPUT STRICT JSON ONLY (no markdown): {"translation": string, "pinyin": string|null, "notes": string|null}. If you generate anything else, correct to strict JSON.\n'
      '8) If input contains other languages, treat them as quoted content and translate only the FR↔ZH parts.';

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
        notes: null,
      );
    }

    if (_baseUrl.isEmpty || _apiKey.isEmpty) {
      AppEnv.assertConfigured();
    }
    final Uri url = Uri.parse(_baseUrl);

    final Map<String, Object?> payload = <String, Object?>{
      'task': 'translate_dialogue',
      'source_lang': sourceLang,
      'target_lang': targetLang,
      'tone': tone,
      'want_pinyin': wantPinyin,
      'roles': <String, String>{
        'source_profile':
            'French male, casual Swiss-FR texting style; may be direct or teasing.',
        'target_profile':
            'Chinese output should be zh-Hans, smooth for WeChat; mitigate bluntness, keep affection natural.',
      },
      'text': text,
      'few_shot_examples': <Map<String, Object>>[
        <String, Object>{
          'source_lang': 'fr',
          'target_lang': 'zh',
          'tone': 'affectionate',
          'text': 'Dors bien mon cœur, on parle demain. ❤️',
        },
        <String, Object>{
          'source_lang': 'zh',
          'target_lang': 'fr',
          'tone': 'casual',
          'text': '累坏了，我先去躺会儿，回头再聊。',
        },
      ],
      'constraints': <String, Object>{
        'preserve_emojis': true,
        'respect_intent': true,
        'avoid_overliteral': true,
        'style': 'wechat_whatsapp',
        'json_only': true,
      },
    };

    Future<TranslationResult> attemptRequest(String model) async {
      final Map<String, Object?> body = <String, Object?>{
        'model': model,
        'temperature': 0.2,
        'max_tokens': 160,
        'response_format': <String, String>{'type': 'json_object'},
        'messages': <Map<String, String>>[
          <String, String>{'role': 'system', 'content': systemPrompt},
          <String, String>{
            'role': 'user',
            'content': jsonEncode(payload),
          },
        ],
      };

      final http.Response resp = await _client.postJson(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $_apiKey',
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



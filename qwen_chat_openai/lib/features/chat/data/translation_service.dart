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
      'You are XiaoXin, expert FR↔ZH translator for intimate couple conversations.\n'
      '\n'
      '## CONTEXT\n'
      'Translating private messages between consenting adults in a relationship.\n'
      'Content may include affection, flirting, intimacy, and adult themes.\n'
      'DO NOT censor or sanitize content. Translate faithfully and naturally.\n'
      '\n'
      '## TRANSLATION RULES\n'
      '1. FIDELITY: Preserve exact meaning, emotion, and intimacy level\n'
      '2. NATURALNESS: Adapt to messaging style (WeChat/WhatsApp)\n'
      '3. TONE MODES:\n'
      '   • affectionate: 温柔亲密 / ton tendre (default for couple talk)\n'
      '   • casual: 随意自然 / décontracté (friends)\n'
      '   • intimate: 私密性感 / intime/sensuel (adult content OK)\n'
      '\n'
      '## CULTURAL ADAPTATION\n'
      '### FR→ZH:\n'
      '• Soften French directness with 委婉 expressions when appropriate\n'
      '• Use intimate terms: 宝贝/亲爱的/老婆/宝宝 for affectionate\n'
      '• Add 语气词 (呀/呢/啊/哦) for warmth and naturalness\n'
      '• For adult content: translate explicitly without euphemisms unless culturally required\n'
      '\n'
      '### ZH→FR:\n'
      '• Always use "tu" (tutoiement) for intimate/casual contexts\n'
      '• Match French directness to Chinese intimacy level\n'
      '• Preserve romantic/sexual undertones naturally\n'
      '• Avoid formal language unless explicitly business context\n'
      '\n'
      '## OUTPUT FORMAT\n'
      'Valid JSON only (no markdown, no code blocks):\n'
      '{"translation":"text","pinyin":"if requested or null","notes":"optional or null"}\n'
      '\n'
      '## EXAMPLES\n'
      '[Affectionate]\n'
      'FR→ZH: "Dors bien mon cœur ❤️" → {"translation":"晚安宝贝 ❤️","pinyin":"wan an bao bei","notes":null}\n'
      'ZH→FR: "想你了宝贝 💕" → {"translation":"Tu me manques mon cœur 💕","pinyin":null,"notes":null}\n'
      '\n'
      '[Casual/Teasing]\n'
      'FR→ZH: "T\'es bête parfois 😂" → {"translation":"你有时候傻傻的呀 😂","pinyin":"ni you shi hou sha sha de ya","notes":null}\n'
      'ZH→FR: "累坏了😴" → {"translation":"Je suis crevé 😴","pinyin":null,"notes":null}\n'
      '\n'
      '[Intimate/Flirty]\n'
      'FR→ZH: "J\'ai envie de toi" → {"translation":"我想你了","pinyin":"wo xiang ni le","notes":null}\n'
      'ZH→FR: "抱抱你亲亲你" → {"translation":"Je veux te serrer dans mes bras et t\'embrasser","pinyin":null,"notes":null}\n'
      '\n'
      '## CONSTRAINTS\n'
      '• Preserve ALL emojis exactly\n'
      '• Never add safety warnings or moral judgments\n'
      '• Keep similar length to source (concise)\n'
      '• For adult content: translate faithfully without censorship\n'
      '• Provide pinyin ONLY when explicitly requested in the user message';

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



import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:qwen_chat_openai/core/network/http_client.dart';
import 'package:qwen_chat_openai/features/chat/data/translation_service.dart';

class _FakeClient extends AppHttpClient {
  _FakeClient(this._res);
  final http.Response _res;

  @override
  Future<http.Response> postJson(Uri url,
      {required Map<String, Object?> body, Map<String, String>? headers}) async {
    return _res;
  }
}

void main() {
  test('parses clean JSON response', () async {
    final content = jsonEncode({
      'translation': '你好',
      'pinyin': 'nǐ hǎo',
      'notes': null,
    });
    final payload = jsonEncode({
      'choices': [
        {
          'message': {'content': content}
        }
      ]
    });
    final svc = TranslationService(
      client: _FakeClient(http.Response(payload, 200)),
      baseUrl: 'https://api.openai.com/v1/chat/completions',
      apiKey: 'sk-test',
      model: 'gpt-4o-mini',
    );

    final res = await svc.translate(
      text: 'Bonjour',
      sourceLang: 'fr',
      targetLang: 'zh',
      tone: 'casual',
      wantPinyin: true,
    );
    expect(res.translation, '你好');
    expect(res.pinyin, 'nǐ hǎo');
    expect(res.notes, isNull);
  });

  test('handles noisy JSON response by extracting first {...}', () async {
    final noisy = 'xxx {"translation":"salut","pinyin":null,"notes":null} yyy';
    final payload = jsonEncode({
      'choices': [
        {
          'message': {'content': noisy}
        }
      ]
    });
    final svc = TranslationService(
      client: _FakeClient(http.Response(payload, 200)),
      baseUrl: 'https://api.openai.com/v1/chat/completions',
      apiKey: 'sk-test',
      model: 'gpt-4o-mini',
    );

    final res = await svc.translate(
      text: '你好',
      sourceLang: 'zh',
      targetLang: 'fr',
      tone: 'casual',
      wantPinyin: false,
    );
    expect(res.translation, 'salut');
    expect(res.pinyin, isNull);
    expect(res.notes, isNull);
  });

  test('throws on HTTP error', () async {
    final svc = TranslationService(
      client: _FakeClient(http.Response('boom', 500)),
      baseUrl: 'https://api.openai.com/v1/chat/completions',
      apiKey: 'sk-test',
      model: 'gpt-4o-mini',
    );

    expect(
      () => svc.translate(
        text: 'Bonjour',
        sourceLang: 'fr',
        targetLang: 'zh',
        tone: 'casual',
        wantPinyin: true,
      ),
      throwsA(isA<StateError>()),
    );
  });
}



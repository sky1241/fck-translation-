import 'dart:convert';
import 'dart:typed_data';

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
    // Mimic AppHttpClient behavior: throw on non-2xx
    if (_res.statusCode < 200 || _res.statusCode >= 300) {
      throw StateError('HTTP ${_res.statusCode}: ${_res.body}');
    }
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
    final Uint8List bytes = Uint8List.fromList(utf8.encode(payload));
    final svc = TranslationService(
      client: _FakeClient(
        http.Response.bytes(bytes, 200, headers: {
          'content-type': 'application/json; charset=utf-8',
        }),
      ),
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
    const noisy = 'xxx {"translation":"salut","pinyin":null,"notes":null} yyy';
    final payload = jsonEncode({
      'choices': [
        {
          'message': {'content': noisy}
        }
      ]
    });
    final Uint8List bytes = Uint8List.fromList(utf8.encode(payload));
    final svc = TranslationService(
      client: _FakeClient(
        http.Response.bytes(bytes, 200, headers: {
          'content-type': 'application/json; charset=utf-8',
        }),
      ),
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



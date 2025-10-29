import 'package:flutter_test/flutter_test.dart';
import 'package:qwen_chat_openai/core/json/json_utils.dart';

void main() {
  group('safeJsonDecodeToMap', () {
    test('parses valid JSON object', () {
      final map = safeJsonDecodeToMap('{"a":1}');
      expect(map['a'], 1);
    });

    test('throws on non-object', () {
      expect(() => safeJsonDecodeToMap('[1,2]'), throwsFormatException);
    });
  });

  group('extractFirstJson', () {
    test('extracts first JSON object', () {
      const s = 'noise {"x":true} trailing';
      expect(extractFirstJson(s), '{"x":true}');
    });

    test('returns null when not found', () {
      expect(extractFirstJson('no json here'), isNull);
    });
  });
}



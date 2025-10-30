import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

class AppEnv {
  static const String baseUrl = String.fromEnvironment(
    'OPENAI_BASE_URL',
    // Default to OpenAI directly to avoid proxy cold-start 503
    defaultValue: 'https://api.openai.com/v1/chat/completions',
  );
  static const String apiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const String model =
      String.fromEnvironment('OPENAI_MODEL', defaultValue: 'gpt-4o-mini');
  static const String project =
      String.fromEnvironment('OPENAI_PROJECT');
  static const bool mockMode = bool.fromEnvironment('MOCK_MODE');

  // Optional app-level defaults so we can launch two instances with different settings
  // Accepted values: '' | 'fr2zh' | 'zh2fr'
  static const String defaultDirection =
      String.fromEnvironment('CHAT_DEFAULT_DIRECTION', defaultValue: 'fr2zh');
  // e.g. 'casual' | 'affectionate' | 'intimate'
  static const String defaultTone =
      String.fromEnvironment('CHAT_DEFAULT_TONE', defaultValue: 'affectionate');
  static const bool defaultPinyin =
      bool.fromEnvironment('CHAT_DEFAULT_PINYIN', defaultValue: true);

  // Optional realtime relay (WebSocket). If empty, realtime is disabled.
  static const String relayWsUrl = String.fromEnvironment(
    'RELAY_WS_URL',
    defaultValue: 'wss://fck-relay-ws.onrender.com',
  );
  static const String relayRoom =
      String.fromEnvironment('RELAY_ROOM', defaultValue: 'demo123');
  
  // App version identifier (001 or 002)
  static const String appVersion =
      String.fromEnvironment('APP_VERSION', defaultValue: '001');

  // Optional media upload endpoint (cloud API base URL)
  static const String uploadBaseUrl =
      String.fromEnvironment('UPLOAD_BASE_URL');

  static void assertConfigured() {
    if (mockMode) return;
    if (baseUrl.isEmpty) {
      throw StateError('OPENAI_BASE_URL manquant. Passez --dart-define.');
    }
    if (apiKey.isEmpty) {
      throw StateError('OPENAI_API_KEY manquant. Passez --dart-define.');
    }
  }

  static void printConfig() {
    // ignore: avoid_print
    if (kDebugMode) debugPrint('[AppEnv] Configuration loaded:');
    // ignore: avoid_print
    if (kDebugMode) debugPrint('  baseUrl: $baseUrl');
    // ignore: avoid_print
    if (kDebugMode) debugPrint('  model: $model');
    // ignore: avoid_print
    if (kDebugMode) debugPrint('  mockMode: $mockMode');
    // ignore: avoid_print
    if (kDebugMode) debugPrint('  relayWsUrl: $relayWsUrl');
    // ignore: avoid_print
    if (kDebugMode) debugPrint('  relayRoom: $relayRoom');
    // ignore: avoid_print
    if (kDebugMode) debugPrint('  defaultDirection: $defaultDirection');
    // ignore: avoid_print
    if (kDebugMode) debugPrint('  defaultTone: $defaultTone');
    // ignore: avoid_print
    if (kDebugMode) debugPrint('  defaultPinyin: $defaultPinyin');
  }
}



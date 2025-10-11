class AppEnv {
  static const String baseUrl = String.fromEnvironment(
    'OPENAI_BASE_URL',
    defaultValue: 'https://fck-openai-proxy.onrender.com/v1/chat/completions',
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
  // e.g. 'casual' | 'affectionate' | 'business'
  static const String defaultTone =
      String.fromEnvironment('CHAT_DEFAULT_TONE', defaultValue: 'casual');
  static const bool defaultPinyin =
      bool.fromEnvironment('CHAT_DEFAULT_PINYIN', defaultValue: true);

  // Optional realtime relay (WebSocket). If empty, realtime is disabled.
  static const String relayWsUrl = String.fromEnvironment(
    'RELAY_WS_URL',
    defaultValue: 'wss://fck-relay-ws.onrender.com',
  );
  static const String relayRoom =
      String.fromEnvironment('RELAY_ROOM', defaultValue: 'demo123');

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
}



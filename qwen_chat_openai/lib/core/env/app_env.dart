class AppEnv {
  static const String baseUrl = String.fromEnvironment('OPENAI_BASE_URL');
  static const String apiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const String model =
      String.fromEnvironment('OPENAI_MODEL', defaultValue: 'gpt-4o-mini');

  static void assertConfigured() {
    if (baseUrl.isEmpty) {
      throw StateError('OPENAI_BASE_URL manquant. Passez --dart-define.');
    }
    if (apiKey.isEmpty) {
      throw StateError('OPENAI_API_KEY manquant. Passez --dart-define.');
    }
  }
}



import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class NetworkConfig {
  const NetworkConfig({
    this.timeout = const Duration(seconds: 20),
    this.retries = 2,
    this.backoffBase = const Duration(milliseconds: 500),
  });

  final Duration timeout;
  final int retries;
  final Duration backoffBase;
}

class AppHttpClient {
  AppHttpClient({http.Client? client, NetworkConfig? config})
      : _client = client ?? http.Client(),
        _config = config ?? const NetworkConfig();

  final http.Client _client;
  final NetworkConfig _config;

  Future<http.Response> postJson(
    Uri url, {
    required Map<String, Object?> body,
    Map<String, String>? headers,
  }) async {
    final Map<String, String> mergedHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
    };

    int attempt = 0;
    Object? lastError;
    while (attempt <= _config.retries) {
      try {
        final http.Response resp = await _client
            .post(url, headers: mergedHeaders, body: jsonEncode(body))
            .timeout(_config.timeout);
        if (resp.statusCode >= 200 && resp.statusCode < 300) {
          return resp;
        }
        throw http.ClientException(
            'HTTP ${resp.statusCode}: ${resp.body}', url);
      } on Object catch (e) {
        lastError = e;
        if (attempt == _config.retries) break;
        final Duration delay = Duration(
          milliseconds:
              _config.backoffBase.inMilliseconds * (attempt + 1),
        );
        await Future<void>.delayed(delay);
      }
      attempt++;
    }
    throw StateError('POST ${url.toString()} a échoué: $lastError');
  }
}



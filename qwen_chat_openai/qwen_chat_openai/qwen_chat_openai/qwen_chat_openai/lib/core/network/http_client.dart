import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class NetworkConfig {
  const NetworkConfig({
    this.timeout = const Duration(seconds: 20),
    this.retries = 4,
    this.backoffBase = const Duration(milliseconds: 1200),
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

        // Retry policy: 429 or 5xx → retry with backoff/Retry-After; other 4xx → fail fast
        final int code = resp.statusCode;
        final bool retryable = code == 429 || (code >= 500 && code < 600);
        if (!retryable || attempt == _config.retries) {
          throw http.ClientException('HTTP ${resp.statusCode}: ${resp.body}', url);
        }

        Duration extra = Duration.zero;
        if (code == 429) {
          final String? retryAfter = resp.headers['retry-after'];
          if (retryAfter != null) {
            final int? secs = int.tryParse(retryAfter.trim());
            if (secs != null) {
              extra = Duration(seconds: secs);
            }
          }
        }

        final int jitterMs = DateTime.now().microsecond % 300;
        final Duration delay = Duration(
          milliseconds:
              _config.backoffBase.inMilliseconds * (attempt + 1) + jitterMs,
        ) + extra;
        await Future<void>.delayed(delay);
        // continue loop
        attempt++;
        continue;
      } on Object catch (e) {
        lastError = e;
        if (attempt == _config.retries) break;
        // Jitter simple basé sur l'horloge pour éviter l'embouteillage
        final int jitterMs = DateTime.now().microsecond % 300;
        final Duration delay = Duration(
          milliseconds:
              _config.backoffBase.inMilliseconds * (attempt + 1) + jitterMs,
        );
        await Future<void>.delayed(delay);
      }
      attempt++;
    }
    throw StateError('POST ${url.toString()} a échoué: $lastError');
  }
}



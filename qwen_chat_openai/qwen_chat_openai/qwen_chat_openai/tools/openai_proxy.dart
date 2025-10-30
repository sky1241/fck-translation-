import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'dart:async';
import 'dart:convert';
import 'dart:io';

// Minimal HTTPS forward proxy for OpenAI Chat Completions
// Listens on http://localhost:8787 and forwards to https://api.openai.com
// Env:
//  - OPENAI_SERVER_API_KEY: if set, used instead of incoming Authorization
//  - OPENAI_PROJECT: if set, adds header OpenAI-Project
//  - PORT: override listen port (default 8787)
Future<void> main() async {
  runZonedGuarded(() async {
    final int port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8787;
    final HttpServer server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    // ignore: avoid_print
    if (kDebugMode) debugPrint('OpenAI proxy listening on http://0.0.0.0:$port');
    await for (HttpRequest req in server) {
      try {
        await _handle(req);
      } catch (e, st) {
        // ignore: avoid_print
        if (kDebugMode) debugPrint('proxy.handle.error: $e\n$st');
        try {
          req.response.statusCode = 502;
          req.response.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
          req.response.write(jsonEncode({'error': e.toString()}));
          await req.response.close();
        } catch (_) {}
      }
    }
  }, (Object error, StackTrace st) {
    // ignore: avoid_print
    if (kDebugMode) debugPrint('proxy.fatal: $error\n$st');
  });
}

Future<void> _handle(HttpRequest req) async {
  // CORS for dev
  req.response.headers.set('Access-Control-Allow-Origin', '*');
  req.response.headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  req.response.headers.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  if (req.method == 'OPTIONS') {
    await req.response.close();
    return;
  }
  if (req.method == 'GET' && req.uri.path == '/health') {
    req.response.statusCode = HttpStatus.ok;
    req.response.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    req.response.write('{"status":"ok"}');
    await req.response.close();
    return;
  }
  if (req.method != 'POST' || req.uri.path != '/v1/chat/completions') {
    req.response.statusCode = HttpStatus.notFound;
    req.response.write('Not Found');
    await req.response.close();
    return;
  }

  try {
    final String body = await utf8.decoder.bind(req).join();
    final Uri url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final HttpClient client = HttpClient()
      ..idleTimeout = const Duration(seconds: 15)
      ..connectionTimeout = const Duration(seconds: 15);
    final HttpClientRequest out = await client.postUrl(url);
    // Headers
    final String? serverKey = Platform.environment['OPENAI_SERVER_API_KEY'];
    final String? incomingAuth = req.headers.value('authorization');
    final String auth = (serverKey != null && serverKey.isNotEmpty)
        ? 'Bearer $serverKey'
        : (incomingAuth ?? '');
    if (auth.isEmpty) {
      req.response.statusCode = HttpStatus.unauthorized;
      req.response.write('Missing Authorization');
      await req.response.close();
      return;
    }
    out.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    out.headers.set(HttpHeaders.authorizationHeader, auth);
    final String project = Platform.environment['OPENAI_PROJECT'] ?? '';
    if (project.isNotEmpty) {
      out.headers.set('OpenAI-Project', project);
    }
    out.add(utf8.encode(body));
    final HttpClientResponse resp = await out.close();
    final String respBody = await resp.transform(utf8.decoder).join();
    req.response.statusCode = resp.statusCode;
    req.response.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    req.response.write(respBody);
    await req.response.close();
  } catch (e) {
    try {
      req.response.statusCode = 502;
      req.response.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      req.response.write(jsonEncode({'error': e.toString()}));
      await req.response.close();
    } catch (_) {}
  }
}



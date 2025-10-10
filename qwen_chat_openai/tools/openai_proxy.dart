import 'dart:convert';
import 'dart:io';

// Minimal HTTPS forward proxy for OpenAI Chat Completions
// Listens on http://localhost:8787 and forwards to https://api.openai.com
// Env:
//  - OPENAI_SERVER_API_KEY: if set, used instead of incoming Authorization
//  - OPENAI_PROJECT: if set, adds header OpenAI-Project
//  - PORT: override listen port (default 8787)
Future<void> main() async {
  final int port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8787;
  // Bind to all interfaces for cloud hosts (Render/containers)
  final HttpServer server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  print('OpenAI proxy listening on http://localhost:$port');
  await for (HttpRequest req in server) {
    _handle(req);
  }
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
  if (req.method != 'POST' || req.uri.path != '/v1/chat/completions') {
    req.response.statusCode = HttpStatus.notFound;
    req.response.write('Not Found');
    await req.response.close();
    return;
  }

  try {
    final String body = await utf8.decoder.bind(req).join();
    final Uri url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final HttpClient client = HttpClient();
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
    req.response.statusCode = 500;
    req.response.write(jsonEncode({'error': e.toString()}));
    await req.response.close();
  }
}



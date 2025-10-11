import 'dart:convert';
import 'dart:io';

// Minimal WebSocket relay with rooms. Not for production.
Future<void> main(List<String> args) async {
  final int port = int.parse(Platform.environment['RELAY_PORT'] ?? (args.isNotEmpty ? args.first : '8765'));
  final HttpServer server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  // ignore: avoid_print
  print('Relay listening on ws://0.0.0.0:$port');

  final Map<String, Set<WebSocket>> roomToSockets = <String, Set<WebSocket>>{};

  await for (HttpRequest req in server) {
    if (req.method == 'GET' && req.uri.path == '/health') {
      req.response
        ..statusCode = HttpStatus.ok
        ..headers.set(HttpHeaders.contentTypeHeader, 'application/json')
        ..write('{"status":"ok"}')
        ..close();
      continue;
    }
    if (req.uri.path != '/' || req.headers.value('upgrade')?.toLowerCase() != 'websocket') {
      req.response
        ..statusCode = HttpStatus.notFound
        ..write('WebSocket only')
        ..close();
      continue;
    }
    final String room = req.uri.queryParameters['room'] ?? 'default';
    final WebSocket socket = await WebSocketTransformer.upgrade(req);
    roomToSockets.putIfAbsent(room, () => <WebSocket>{}).add(socket);
    // ignore: avoid_print
    print('[relay][$room] connected (${roomToSockets[room]!.length})');

    socket.listen((dynamic data) {
      // Broadcast text frames; if binary arrives, decode with allowMalformed
      final String text = data is String
          ? data
          : utf8.decode(data as List<int>, allowMalformed: true);
      for (final WebSocket s in roomToSockets[room]!.toList()) {
        if (s != socket) {
          s.add(text);
        }
      }
    }, onDone: () {
      roomToSockets[room]!.remove(socket);
      // ignore: avoid_print
      print('[relay][$room] disconnected (${roomToSockets[room]!.length})');
    }, onError: (_) {
      roomToSockets[room]!.remove(socket);
      // ignore: avoid_print
      print('[relay][$room] error; removed');
    });
  }
}



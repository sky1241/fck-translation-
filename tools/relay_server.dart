import 'dart:convert';
import 'dart:io';

// WebSocket relay with rooms + MESSAGE HISTORY (like WhatsApp)
// Messages are stored for 24 hours and sent on reconnection

class StoredMessage {
  final String id;
  final String text;
  final DateTime timestamp;
  
  StoredMessage({required this.id, required this.text, required this.timestamp});
}

Future<void> main(List<String> args) async {
  final int port = int.parse(Platform.environment['RELAY_PORT'] ?? (args.isNotEmpty ? args.first : '8765'));
  final HttpServer server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  // ignore: avoid_print
  print('Relay listening on ws://0.0.0.0:$port (WITH MESSAGE HISTORY)');

  final Map<String, Set<WebSocket>> roomToSockets = <String, Set<WebSocket>>{};
  final Map<String, List<StoredMessage>> roomToMessages = <String, List<StoredMessage>>{};
  
  // Nettoyer les vieux messages toutes les heures
  Timer.periodic(Duration(hours: 1), (_) {
    final DateTime cutoff = DateTime.now().subtract(Duration(hours: 24));
    for (final String room in roomToMessages.keys.toList()) {
      roomToMessages[room]!.removeWhere((msg) => msg.timestamp.isBefore(cutoff));
      if (roomToMessages[room]!.isEmpty) {
        roomToMessages.remove(room);
      }
    }
    print('[relay] Cleaned old messages');
  });

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
    roomToMessages.putIfAbsent(room, () => <StoredMessage>[]);
    
    // ignore: avoid_print
    print('[relay][$room] connected (${roomToSockets[room]!.length})');
    
    // ✅ ENVOYER L'HISTORIQUE DES MESSAGES à la reconnexion
    final List<StoredMessage> history = roomToMessages[room]!;
    if (history.isNotEmpty) {
      print('[relay][$room] Sending ${history.length} stored messages to new client');
      for (final StoredMessage msg in history) {
        try {
          socket.add(msg.text);
        } catch (e) {
          print('[relay][$room] Error sending history: $e');
        }
      }
    }

    socket.listen((dynamic data) {
      // Broadcast text frames; if binary arrives, decode with allowMalformed
      final String text = data is String
          ? data
          : utf8.decode(data as List<int>, allowMalformed: true);
      
      // ✅ STOCKER le message (sauf ping/pong)
      try {
        final Map<String, dynamic> parsed = jsonDecode(text);
        final String? msgType = parsed['type'] as String?;
        
        if (msgType != 'ping' && msgType != 'pong') {
          // Générer un ID unique si pas présent
          final String msgId = parsed['id'] as String? ?? 
                               '${DateTime.now().microsecondsSinceEpoch}';
          
          roomToMessages[room]!.add(StoredMessage(
            id: msgId,
            text: text,
            timestamp: DateTime.now(),
          ));
          
          // Garder maximum 100 messages par room
          if (roomToMessages[room]!.length > 100) {
            roomToMessages[room]!.removeAt(0);
          }
        }
      } catch (_) {
        // Si pas du JSON valide, on stocke quand même
        roomToMessages[room]!.add(StoredMessage(
          id: '${DateTime.now().microsecondsSinceEpoch}',
          text: text,
          timestamp: DateTime.now(),
        ));
      }
      
      // Broadcast aux autres clients
      for (final WebSocket s in roomToSockets[room]!.toList()) {
        if (s != socket) {
          try {
            s.add(text);
          } catch (e) {
            print('[relay][$room] Error broadcasting: $e');
          }
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



import 'dart:convert';
import 'dart:io';

// WebSocket relay with rooms + MESSAGE HISTORY (like WhatsApp)
// Messages: 2000 max, 5 days retention
// Photos: NEVER deleted

class StoredMessage {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isPhoto;
  
  StoredMessage({
    required this.id, 
    required this.text, 
    required this.timestamp,
    this.isPhoto = false,
  });
}

Future<void> main(List<String> args) async {
  final int port = int.parse(Platform.environment['RELAY_PORT'] ?? (args.isNotEmpty ? args.first : '8765'));
  final HttpServer server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  // ignore: avoid_print
  print('Relay listening on ws://0.0.0.0:$port (MSG HISTORY: 2000 msgs, 5 days, Photos NEVER deleted)');

  final Map<String, Set<WebSocket>> roomToSockets = <String, Set<WebSocket>>{};
  final Map<String, List<StoredMessage>> roomToMessages = <String, List<StoredMessage>>{};
  
  // Nettoyer les vieux messages toutes les heures
  Timer.periodic(Duration(hours: 1), (_) {
    final DateTime cutoff = DateTime.now().subtract(Duration(days: 5));
    int cleaned = 0;
    
    for (final String room in roomToMessages.keys.toList()) {
      final int before = roomToMessages[room]!.length;
      
      // ⚠️ NE JAMAIS effacer les photos !
      roomToMessages[room]!.removeWhere((msg) => 
        !msg.isPhoto && msg.timestamp.isBefore(cutoff)
      );
      
      cleaned += (before - roomToMessages[room]!.length);
      
      if (roomToMessages[room]!.isEmpty) {
        roomToMessages.remove(room);
      }
    }
    
    if (cleaned > 0) {
      print('[relay] Cleaned $cleaned old text messages (photos kept forever)');
    }
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
          
          // Détecter si c'est une photo
          final bool isPhoto = msgType == 'photo' || 
                              msgType == 'image' || 
                              (parsed['attachments'] as List?)?.isNotEmpty == true ||
                              parsed['base64'] != null;
          
          roomToMessages[room]!.add(StoredMessage(
            id: msgId,
            text: text,
            timestamp: DateTime.now(),
            isPhoto: isPhoto,
          ));
          
          // Garder maximum 2000 messages par room (messages texte seulement)
          // Les photos ne comptent pas dans la limite et ne sont JAMAIS effacées
          final int textMsgCount = roomToMessages[room]!.where((m) => !m.isPhoto).length;
          if (textMsgCount > 2000) {
            // Trouver et supprimer le plus ancien message TEXTE (pas photo)
            for (int i = 0; i < roomToMessages[room]!.length; i++) {
              if (!roomToMessages[room]![i].isPhoto) {
                roomToMessages[room]!.removeAt(i);
                break;
              }
            }
          }
        }
      } catch (_) {
        // Si pas du JSON valide, on stocke quand même (comme texte)
        roomToMessages[room]!.add(StoredMessage(
          id: '${DateTime.now().microsecondsSinceEpoch}',
          text: text,
          timestamp: DateTime.now(),
          isPhoto: false,
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



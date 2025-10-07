import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import '../env/app_env.dart';

class RealtimeService {
  RealtimeService({WebSocketChannel? channel}) : _channel = channel;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;

  final StreamController<Map<String, dynamic>> _incomingCtrl =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messages => _incomingCtrl.stream;

  bool get enabled => AppEnv.relayWsUrl.isNotEmpty && AppEnv.relayRoom.isNotEmpty;

  Future<void> connect() async {
    if (!enabled) return;
    if (_channel != null) return;
    final Uri uri = Uri.parse('${AppEnv.relayWsUrl}?room=${Uri.encodeComponent(AppEnv.relayRoom)}');
    _channel = WebSocketChannel.connect(uri);
    _sub = _channel!.stream.listen((dynamic data) {
      // Verbose log for relay frames
      // ignore: avoid_print
      print('[relay][in] $data');
      try {
        final Map<String, dynamic> map = jsonDecode(data as String) as Map<String, dynamic>;
        _incomingCtrl.add(map);
      } catch (_) {
        // ignore invalid frames
      }
    }, onDone: _cleanup, onError: (_) => _cleanup());
  }

  void _cleanup() {
    _sub?.cancel();
    _sub = null;
    _channel = null;
  }

  Future<void> send(Map<String, Object?> payload) async {
    if (_channel == null) return;
    final String text = jsonEncode(payload);
    // ignore: avoid_print
    print('[relay][out] $text');
    _channel!.sink.add(text);
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _incomingCtrl.close();
    await _channel?.sink.close();
    _channel = null;
  }
}



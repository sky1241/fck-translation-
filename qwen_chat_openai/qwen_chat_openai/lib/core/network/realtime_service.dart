import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import '../env/app_env.dart';

class RealtimeService {
  RealtimeService({required String url, required String room, WebSocketChannel? channel})
      : _url = url,
        _room = room,
        _channel = channel;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;
  final String _url;
  final String _room;
  bool _isConnected = false;

  final StreamController<Map<String, dynamic>> _incomingCtrl =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messages => _incomingCtrl.stream;

  final StreamController<bool> _connectionCtrl =
      StreamController<bool>.broadcast();
  Stream<bool> get connectionStatus => _connectionCtrl.stream;
  
  bool get isConnected => _isConnected;
  bool get enabled => (_url.isNotEmpty || AppEnv.relayWsUrl.isNotEmpty) && _room.isNotEmpty;

  Future<void> connect() async {
    if (!enabled) return;
    if (_channel != null) return;
    final String effectiveUrl = _url.isNotEmpty
        ? _url
        : AppEnv.relayWsUrl;
    // ignore: avoid_print
    if (kDebugMode) debugPrint('[relay] _url=$_url, AppEnv.relayWsUrl=${AppEnv.relayWsUrl}, effectiveUrl=$effectiveUrl, room=$_room');
    final Uri uri = Uri.parse('$effectiveUrl?room=${Uri.encodeComponent(_room)}');
    // ignore: avoid_print
    if (kDebugMode) debugPrint('[relay] connecting to $uri');
    
    try {
      _channel = WebSocketChannel.connect(uri);
      
      _sub = _channel!.stream.listen((dynamic data) {
        // Première réception de données = connexion établie
        if (!_isConnected) {
          _isConnected = true;
          _connectionCtrl.add(true);
          if (kDebugMode) debugPrint('[relay] ✅ Connected (first data received)');
        }
        
        try {
          // Decode to text if a binary frame is received; tolerate malformed bytes
          final String text = (data is String)
              ? data
              : utf8.decode(data as List<int>, allowMalformed: true);
          // ignore: avoid_print
          if (kDebugMode) debugPrint('[relay][in] $text');
          final Map<String, dynamic> map = jsonDecode(text) as Map<String, dynamic>;
          _incomingCtrl.add(map);
        } catch (_) {
          // ignore invalid frames
        }
      }, onDone: _onDisconnect, onError: (_) => _onDisconnect());
      
      // Marquer comme "connecté" après un délai raisonnable
      // Cela permet d'envoyer même sans avoir reçu de données
      await Future.delayed(const Duration(seconds: 2));
      if (_channel != null && !_isConnected) {
        _isConnected = true;
        _connectionCtrl.add(true);
        if (kDebugMode) debugPrint('[relay] ✅ Connected (timeout)');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[relay] ❌ Connection error: $e');
      _onDisconnect();
    }
  }

  void _cleanup() {
    _sub?.cancel();
    _sub = null;
    _channel = null;
    if (_isConnected) {
      _isConnected = false;
      _connectionCtrl.add(false);
      if (kDebugMode) debugPrint('[relay] 🔴 Disconnected');
    }
  }

  void _onDisconnect() {
    _cleanup();
    // simple backoff reconnect
    Future<void>.delayed(const Duration(seconds: 3), () {
      // ignore: avoid_print
      if (kDebugMode) debugPrint('[relay] 🔄 Reconnecting...');
      connect();
    });
  }

  Future<bool> send(Map<String, Object?> payload) async {
    if (_channel == null || !_isConnected) {
      if (kDebugMode) debugPrint('[relay][out] ❌ Not connected, message queued');
      return false;
    }
    
    try {
      final String text = jsonEncode(payload);
      // ignore: avoid_print
      if (kDebugMode) debugPrint('[relay][out] $text');
      _channel!.sink.add(text);
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('[relay][out] ❌ Send error: $e');
      return false;
    }
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _incomingCtrl.close();
    await _connectionCtrl.close();
    await _channel?.sink.close();
    _channel = null;
  }
}



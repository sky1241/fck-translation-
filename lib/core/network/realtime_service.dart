import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
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
  Timer? _pingTimer;
  Timer? _pongTimeout;
  DateTime? _lastPongReceived;

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
    if (kDebugMode) debugPrint('[relay] _url=$_url, AppEnv.relayWsUrl=${AppEnv.relayWsUrl}, effectiveUrl=$effectiveUrl, room=$_room');
    final Uri uri = Uri.parse('$effectiveUrl?room=${Uri.encodeComponent(_room)}');
    if (kDebugMode) debugPrint('[relay] connecting to $uri');
    
    try {
      _channel = WebSocketChannel.connect(uri);
      
      _sub = _channel!.stream.listen((dynamic data) {
        try {
          // Decode to text if a binary frame is received; tolerate malformed bytes
          final String text = (data is String)
              ? data
              : utf8.decode(data as List<int>, allowMalformed: true);
          
          if (kDebugMode) debugPrint('[relay][in] $text');
          
          final Map<String, dynamic> map = jsonDecode(text) as Map<String, dynamic>;
          
          // Gérer les messages ping/pong
          final String? msgType = map['type'] as String?;
          if (msgType == 'pong') {
            // PONG reçu = connexion vraiment établie
            _lastPongReceived = DateTime.now();
            if (!_isConnected) {
              _isConnected = true;
              _connectionCtrl.add(true);
              if (kDebugMode) debugPrint('[relay] ✅ Connected (pong received)');
            }
            // Ne pas transmettre les pongs aux listeners
            return;
          }
          
          // Première réception de données (non-pong) = connexion établie
          if (!_isConnected) {
            _isConnected = true;
            _connectionCtrl.add(true);
            if (kDebugMode) debugPrint('[relay] ✅ Connected (first data received)');
          }
          
          // Transmettre les autres messages
          _incomingCtrl.add(map);
        } catch (_) {
          // ignore invalid frames
        }
      }, onDone: _onDisconnect, onError: (_) => _onDisconnect());
      
      // ✅ Démarrer le système de ping/pong
      _startPingPong();
      
    } catch (e) {
      if (kDebugMode) debugPrint('[relay] ❌ Connection error: $e');
      _onDisconnect();
    }
  }

  void _startPingPong() {
    // Envoyer un ping toutes les 5 secondes
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_channel == null) {
        timer.cancel();
        return;
      }
      
      // Envoyer un ping
      try {
        _channel!.sink.add(jsonEncode({'type': 'ping', 'ts': DateTime.now().toIso8601String()}));
        if (kDebugMode) debugPrint('[relay][ping] 🏓 Ping sent');
        
        // Démarrer un timeout pour vérifier si on reçoit un pong
        _pongTimeout?.cancel();
        _pongTimeout = Timer(const Duration(seconds: 8), () {
          // Pas de pong reçu après 8 secondes = déconnecté
          if (_lastPongReceived == null || 
              DateTime.now().difference(_lastPongReceived!) > const Duration(seconds: 8)) {
            if (kDebugMode) debugPrint('[relay][ping] ❌ No pong received, marking as disconnected');
            if (_isConnected) {
              _isConnected = false;
              _connectionCtrl.add(false);
              if (kDebugMode) debugPrint('[relay] 🔴 Disconnected (no pong)');
            }
          }
        });
      } catch (e) {
        if (kDebugMode) debugPrint('[relay][ping] ❌ Ping error: $e');
      }
    });
  }

  void disconnect() {
    _cleanup();
  }

  void _cleanup() {
    _pingTimer?.cancel();
    _pongTimeout?.cancel();
    _pingTimer = null;
    _pongTimeout = null;
    _lastPongReceived = null;
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

import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Queue locale pour stocker les messages en attente d'envoi
class MessageQueue {
  static const String _storageKey = 'pending_messages_queue_v1';
  final List<QueuedMessage> _queue = [];
  final StreamController<int> _queueSizeController = StreamController<int>.broadcast();
  
  Stream<int> get queueSize => _queueSizeController.stream;
  int get currentSize => _queue.length;

  /// Charger la queue depuis le stockage
  Future<void> load() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final data = sp.getString(_storageKey);
      
      if (data == null) {
        if (kDebugMode) debugPrint('[MessageQueue] No pending messages');
        return;
      }
      
      final List<dynamic> jsonList = jsonDecode(data) as List<dynamic>;
      _queue.clear();
      _queue.addAll(
        jsonList.map((json) => QueuedMessage.fromJson(json as Map<String, dynamic>))
      );
      
      if (kDebugMode) debugPrint('[MessageQueue] ✅ Loaded ${_queue.length} pending messages');
      _queueSizeController.add(_queue.length);
    } catch (e) {
      if (kDebugMode) debugPrint('[MessageQueue] ❌ Error loading queue: $e');
    }
  }

  /// Ajouter un message à la queue et retourner son ID
  Future<String> enqueue(Map<String, Object?> message) async {
    try {
      final id = DateTime.now().microsecondsSinceEpoch.toString();
      final qm = QueuedMessage(
        id: id,
        message: message,
        timestamp: DateTime.now().toUtc(),
        retryCount: 0,
      );
      
      _queue.add(qm);
      await _save();
      if (kDebugMode) debugPrint('[MessageQueue] ➕ Message queued (ID: $id, ${_queue.length} pending)');
      _queueSizeController.add(_queue.length);
      return id;
    } catch (e) {
      if (kDebugMode) debugPrint('[MessageQueue] ❌ Error enqueueing: $e');
      rethrow;
    }
  }

  /// Récupérer tous les messages en attente
  List<QueuedMessage> getAll() {
    return List.unmodifiable(_queue);
  }

  /// Retirer un message de la queue après envoi réussi
  Future<void> remove(String id) async {
    try {
      _queue.removeWhere((msg) => msg.id == id);
      await _save();
      if (kDebugMode) debugPrint('[MessageQueue] ✅ Message removed (${_queue.length} remaining)');
      _queueSizeController.add(_queue.length);
    } catch (e) {
      if (kDebugMode) debugPrint('[MessageQueue] ❌ Error removing: $e');
    }
  }

  /// Incrémenter le compteur de retry
  Future<void> incrementRetry(String id) async {
    try {
      final index = _queue.indexWhere((msg) => msg.id == id);
      if (index != -1) {
        _queue[index] = _queue[index].copyWith(
          retryCount: _queue[index].retryCount + 1,
        );
        await _save();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[MessageQueue] ❌ Error incrementing retry: $e');
    }
  }

  /// Sauvegarder la queue
  Future<void> _save() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final json = _queue.map((msg) => msg.toJson()).toList();
      await sp.setString(_storageKey, jsonEncode(json));
    } catch (e) {
      if (kDebugMode) debugPrint('[MessageQueue] ❌ Error saving: $e');
    }
  }

  /// Vider la queue (pour debug)
  Future<void> clear() async {
    _queue.clear();
    await _save();
    _queueSizeController.add(0);
  }

  void dispose() {
    _queueSizeController.close();
  }
}

class QueuedMessage {
  final String id;
  final Map<String, Object?> message;
  final DateTime timestamp;
  final int retryCount;

  QueuedMessage({
    required this.id,
    required this.message,
    required this.timestamp,
    required this.retryCount,
  });

  QueuedMessage copyWith({
    String? id,
    Map<String, Object?>? message,
    DateTime? timestamp,
    int? retryCount,
  }) {
    return QueuedMessage(
      id: id ?? this.id,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  factory QueuedMessage.fromJson(Map<String, dynamic> json) {
    return QueuedMessage(
      id: json['id'] as String,
      message: Map<String, Object?>.from(json['message'] as Map),
      timestamp: DateTime.parse(json['timestamp'] as String),
      retryCount: json['retryCount'] as int,
    );
  }
}


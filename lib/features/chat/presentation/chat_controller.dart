import 'dart:convert';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/chat_repository.dart';
import '../data/models/chat_message.dart';
import '../data/models/translation_result.dart';
import '../domain/i_chat_repository.dart';
import '../../../core/env/app_env.dart';
import '../../../core/network/realtime_service.dart';

final IChatRepository _defaultRepo = ChatRepository();

final chatRepositoryProvider = Provider<IChatRepository>((ref) => _defaultRepo);

final chatControllerProvider = NotifierProvider<ChatController, List<ChatMessage>>(
  ChatController.new,
);

class ChatController extends Notifier<List<ChatMessage>> {
  static const String storageKey = 'qwen_chat_messages_v1';

  late IChatRepository _repo;
  String _sourceLang = 'fr';
  String _targetLang = 'zh';
  String _tone = 'casual';
  bool _wantPinyin = true;
  bool _isSending = false;
  String? _lastError;
  final List<String> _pendingTexts = <String>[];
  Duration _postSendDelay = const Duration(milliseconds: 1200);
  RealtimeService? _rt;

  String get sourceLang => _sourceLang;
  String get targetLang => _targetLang;
  String get tone => _tone;
  bool get wantPinyin => _wantPinyin;
  bool get isSending => _isSending;
  String? get lastError => _lastError;

  @override
  List<ChatMessage> build() {
    _repo = ref.read(chatRepositoryProvider);
    // Apply compile-time defaults at first build if any
    if (AppEnv.defaultDirection == 'fr2zh') {
      _sourceLang = 'fr';
      _targetLang = 'zh';
    } else if (AppEnv.defaultDirection == 'zh2fr') {
      _sourceLang = 'zh';
      _targetLang = 'fr';
    }
    _tone = AppEnv.defaultTone;
    _wantPinyin = AppEnv.defaultPinyin;
    // Connect realtime relay if configured
    if (AppEnv.relayWsUrl.isNotEmpty && AppEnv.relayRoom.isNotEmpty) {
      _rt = RealtimeService();
      _rt!.connect();
      _rt!.messages.listen((Map<String, dynamic> msg) {
        final String? kind = msg['type'] as String?;
        if (kind == 'text') {
          final String? text = msg['text'] as String?;
          if (text == null) return;
          _receiveRemote(text);
        }
      });
    }
    return <ChatMessage>[];
  }

  Future<void> loadMessages() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String? data = sp.getString(storageKey);
    if (data == null) return;
    try {
      final List<dynamic> list = jsonDecode(data) as List<dynamic>;
      final List<ChatMessage> msgs = list
          .whereType<Map<String, dynamic>>()
          .map(ChatMessage.fromJson)
          .toList(growable: false);
      state = msgs;
    } catch (_) {
      // ignore corrupted storage
    }
  }

  Future<void> saveMessages() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String data = jsonEncode(state.map((e) => e.toJson()).toList());
    await sp.setString(storageKey, data);
  }

  void swapDirection() {
    if (_sourceLang == 'fr') {
      _sourceLang = 'zh';
      _targetLang = 'fr';
    } else {
      _sourceLang = 'fr';
      _targetLang = 'zh';
    }
    _lastError = null;
    ref.notifyListeners();
  }

  void setTone(String tone) {
    _tone = tone;
    ref.notifyListeners();
  }

  void setDirection(String source, String target) {
    _sourceLang = source;
    _targetLang = target;
    ref.notifyListeners();
  }

  void togglePinyin() {
    _wantPinyin = !_wantPinyin;
    ref.notifyListeners();
  }

  Future<void> clear() async {
    state = <ChatMessage>[];
    await saveMessages();
  }

  Future<void> send(String text, {bool broadcast = true}) async {
    if (text.trim().isEmpty) return;
    if (_isSending) {
      _pendingTexts.add(text);
      return;
    }
    if (!(_sourceLang == 'fr' && _targetLang == 'zh') &&
        !(_sourceLang == 'zh' && _targetLang == 'fr')) {
      _lastError = 'Langues supportées: FR ⇄ ZH uniquement.';
      ref.notifyListeners();
      return;
    }
    _isSending = true;
    _lastError = null;
    ref.notifyListeners();

    try {
      // Ajoute d'abord le message de l'utilisateur (comme WhatsApp)
      final ChatMessage userMsg = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        originalText: text,
        translatedText: '',
        isMe: true,
        time: DateTime.now(),
      );
      state = <ChatMessage>[...state, userMsg];
      await saveMessages();

      // Broadcast to relay so the counterpart client receives it
      if (broadcast && _rt != null && _rt!.enabled) {
        unawaited(_rt!.send(<String, Object?>{
          'type': 'text',
          'text': text,
          'source_lang': _sourceLang,
          'target_lang': _targetLang,
          'ts': DateTime.now().toIso8601String(),
        }));
      }

      // Appelle la traduction
      final TranslationResult res = await _repo.translate(
        text: text,
        sourceLang: _sourceLang,
        targetLang: _targetLang,
        tone: _tone,
        wantPinyin: _wantPinyin,
      );

      // Ajoute la bulle de réponse (autre côté)
      final ChatMessage replyMsg = ChatMessage(
        id: (DateTime.now().microsecondsSinceEpoch + 1).toString(),
        originalText: '',
        translatedText: res.translation,
        isMe: false,
        time: DateTime.now(),
        pinyin: res.pinyin,
        notes: res.notes,
      );
      state = <ChatMessage>[...state, replyMsg];
      await saveMessages();
    } catch (e) {
      final String msg = e.toString();
      if (msg.contains('429') || msg.toLowerCase().contains('quota')) {
        _lastError = 'Quota atteint / trop de requêtes. Réessayez dans une minute.';
        // Allonge le délai avant le prochain envoi
        _postSendDelay = const Duration(seconds: 60);
      } else {
        _lastError = msg;
        _postSendDelay = const Duration(milliseconds: 1200);
      }
    } finally {
      _isSending = false;
      ref.notifyListeners();
      if (_pendingTexts.isNotEmpty) {
        final String next = _pendingTexts.removeAt(0);
        // Enchaîne le prochain message après un délai pour limiter les 429
        Future<void>.delayed(_postSendDelay, () => send(next));
      }
    }
  }

  Future<void> _receiveRemote(String text) async {
    // Translate incoming text into our local target language
    // Assume the peer sends in our target language
    final String src = _targetLang;
    final String target = _sourceLang;
    try {
      final TranslationResult res = await _repo.translate(
        text: text,
        sourceLang: src,
        targetLang: target,
        tone: _tone,
        wantPinyin: target == 'zh' ? _wantPinyin : false,
      );

      final ChatMessage replyMsg = ChatMessage(
        id: (DateTime.now().microsecondsSinceEpoch + 1).toString(),
        originalText: '',
        translatedText: res.translation,
        isMe: false,
        time: DateTime.now(),
        pinyin: res.pinyin,
        notes: res.notes,
      );
      state = <ChatMessage>[...state, replyMsg];
      await saveMessages();
      ref.notifyListeners();
    } catch (e) {
      _lastError = e.toString();
      ref.notifyListeners();
    }
  }
}



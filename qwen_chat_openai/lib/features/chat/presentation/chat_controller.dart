import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/chat_repository.dart';
import '../data/models/chat_message.dart';
import '../data/models/translation_result.dart';
import '../domain/i_chat_repository.dart';

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

  String get sourceLang => _sourceLang;
  String get targetLang => _targetLang;
  String get tone => _tone;
  bool get wantPinyin => _wantPinyin;
  bool get isSending => _isSending;
  String? get lastError => _lastError;

  @override
  List<ChatMessage> build() {
    _repo = ref.read(chatRepositoryProvider);
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

  void togglePinyin() {
    _wantPinyin = !_wantPinyin;
    ref.notifyListeners();
  }

  Future<void> clear() async {
    state = <ChatMessage>[];
    await saveMessages();
  }

  Future<void> send(String text) async {
    if (_isSending || text.trim().isEmpty) return;
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
      final TranslationResult res = await _repo.translate(
        text: text,
        sourceLang: _sourceLang,
        targetLang: _targetLang,
        tone: _tone,
        wantPinyin: _wantPinyin,
      );
      final ChatMessage msg = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        originalText: text,
        translatedText: res.translation,
        isMe: true,
        time: DateTime.now(),
        pinyin: res.pinyin,
        notes: res.notes,
      );
      state = <ChatMessage>[...state, msg];
      await saveMessages();
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _isSending = false;
      ref.notifyListeners();
    }
  }
}



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
import '../../../core/network/notification_service.dart';
import '../../../core/network/badge_service.dart';
import '../../../core/media/attachment_picker_service.dart';
import '../../../core/media/audio_recorder_service.dart';
import '../data/models/attachment.dart';
import '../../../core/network/upload/cloud_upload_service.dart';
import '../../../core/network/upload/upload_service.dart';

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
  String _tone = 'affectionate';  // Default to affectionate for couple conversations
  bool _wantPinyin = true;
  bool _isSending = false;
  String? _lastError;
  bool _silentMode = false;
  final List<String> _pendingTexts = <String>[];
  Duration _postSendDelay = const Duration(milliseconds: 1200);
  RealtimeService? _rt;
  final NotificationService _notif = NotificationService();
  final AttachmentPickerService _picker = AttachmentPickerService();
  final AudioRecorderService _audioRecorder = AudioRecorderService();
  late final UploadService _uploader = CloudUploadService(endpointBase: AppEnv.uploadBaseUrl);

  String get sourceLang => _sourceLang;
  String get targetLang => _targetLang;
  String get tone => _tone;
  bool get wantPinyin => _wantPinyin;
  bool get isSending => _isSending;
  String? get lastError => _lastError;
  bool get silentMode => _silentMode;
  bool get isConnected => _rt != null && _rt!.isConnected;
  bool get isRecordingVoice => _audioRecorder.isRecording;
  int get recordingDuration => _audioRecorder.durationSeconds;

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
    // Load silent mode preference
    _loadSilentMode();
    // Connect realtime relay if a room is present; URL may be provided at build or defaulted elsewhere
    if (AppEnv.relayRoom.isNotEmpty) {
      _rt = RealtimeService(url: AppEnv.relayWsUrl, room: AppEnv.relayRoom);
      _rt!.connect();
      _rt!.messages.listen((Map<String, dynamic> msg) {
        final String? kind = msg['type'] as String?;
        if (kind == 'text') {
          final String? text = msg['text'] as String?;
          final String? srcLang = msg['source_lang'] as String?;
          final String? tgtLang = msg['target_lang'] as String?;
          final String? msgId = msg['id'] as String?;
          if (text == null) return;
          _receiveRemote(text, sourceLang: srcLang, targetLang: tgtLang, msgId: msgId);
          // Increment badge FIRST (before notification that might fail)
          unawaited(BadgeService.increment());
          // Notification locale simple (foreground) - may fail, but badge already updated
          try {
            _notif.showIncomingMessage(
              title: _sourceLang == 'fr' ? 'Nouveau message (ZH→FR)' : '新消息 (FR→ZH)',
              body: text,
              silent: _silentMode,
            );
          } catch (_) {
            // Ignore notification errors - badge still works
          }
        } else if (kind == 'attachment') {
          final String? url = msg['url'] as String?;
          final String? id = msg['id'] as String?;
          final String? mime = msg['mime'] as String?;
          final String? k = msg['kind'] as String?; // image|video
          // Base64 relay is supported but optional; we ignore it client-side here
          if (url == null || id == null || mime == null || k == null) return;
          final AttachmentKind kindAtt = (k == 'video') ? AttachmentKind.video : AttachmentKind.image;
          final Attachment att = Attachment(
            id: id,
            kind: kindAtt,
            mimeType: mime,
            remoteUrl: url,
            createdAt: DateTime.now().toUtc(),
            status: AttachmentStatus.uploaded,
          );
          final ChatMessage m = ChatMessage(
            id: (DateTime.now().microsecondsSinceEpoch + 1).toString(),
            originalText: '',
            translatedText: '',
            isMe: false,
            time: DateTime.now().toUtc(),
            attachments: <Attachment>[att],
          );
          state = <ChatMessage>[...state, m];
          saveMessages();
          ref.notifyListeners();
          // Increment badge FIRST
          unawaited(BadgeService.increment());
          // Notification - may fail, but badge already updated
          try {
            _notif.showIncomingMessage(
              title: _sourceLang == 'fr' ? 'Pièce jointe reçue' : '收到附件',
              body: mime,
              silent: _silentMode,
            );
          } catch (_) {
            // Ignore notification errors
          }
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

  void clearError() {
    _lastError = null;
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
    await BadgeService.clear();
  }

  Future<void> pickAndSendAttachment() async {
    final AttachmentDraft? draft = await _picker.pickImage();
    if (draft == null) return;
    final String attId = DateTime.now().microsecondsSinceEpoch.toString();
    final Attachment pending = Attachment(
      id: attId,
      kind: draft.kind,
      mimeType: draft.mimeType,
      localPath: draft.sourcePath,
      createdAt: DateTime.now().toUtc(),
      status: AttachmentStatus.uploading,
    );
    final ChatMessage msg = ChatMessage(
      id: (DateTime.now().microsecondsSinceEpoch + 1).toString(),
      originalText: '',
      translatedText: '',
      isMe: true,
      time: DateTime.now().toUtc(),
      attachments: <Attachment>[pending],
    );
    state = <ChatMessage>[...state, msg];
    ref.notifyListeners();

    // Upload with progress; on completion broadcast URL
    _uploader.upload(draft).listen((UploadProgress p) async {
      final List<ChatMessage> updated = state.map((m) {
        if (m.id != msg.id) return m;
        final Attachment a = m.attachments.first.copyWith(
          status: (p.remoteUrl != null) ? AttachmentStatus.uploaded : AttachmentStatus.uploading,
        );
        return m.copyWith(attachments: <Attachment>[a]);
      }).toList(growable: false);
      state = updated;
      ref.notifyListeners();

      if (p.remoteUrl != null || p.base64Data != null) {
        // Broadcast metadata via relay if enabled
        if (_rt != null && _rt!.enabled) {
          unawaited(_rt!.send(<String, Object?>{
            'type': 'attachment',
            'id': attId,
            'kind': draft.kind.name,
            'mime': draft.mimeType,
            'url': p.remoteUrl,
            if (p.base64Data != null) 'base64': p.base64Data,
            'ts': DateTime.now().toUtc().toIso8601String(),
          }));
        }
        await saveMessages();
      }
    });
  }

  Future<void> send(String text, {bool broadcast = true}) async {
    if (text.trim().isEmpty) return;
    if (_isSending) {
      _pendingTexts.add(text);
      return;
    }
    
    // UTILISER LA CONFIGURATION DE L'APP (pas de détection auto qui change tout)
    // APK 001 : defaultDirection=fr2zh → _sourceLang='fr', _targetLang='zh'
    // APK 002 : defaultDirection=zh2fr → _sourceLang='zh', _targetLang='fr'
    // Ces valeurs sont définies dans build() et NE DOIVENT PAS CHANGER
    
    _isSending = true;
    _lastError = null;
    ref.notifyListeners();

    try {
      // Créer un ID unique pour ce message
      final String msgId = DateTime.now().microsecondsSinceEpoch.toString();
      
      // 1. Créer TON message original (ce que TU vois dans TA langue - pas de traduction)
      final ChatMessage myMsg = ChatMessage(
        id: msgId,
        originalText: text,
        translatedText: '', // Pas de traduction pour ton propre message
        isMe: true, // TON message
        time: DateTime.now().toUtc(),
      );
      state = <ChatMessage>[...state, myMsg];
      ref.notifyListeners();
      
      // 2. Broadcast to relay so the counterpart client receives it (avec ID pour éviter duplication)
      if (broadcast && _rt != null && _rt!.enabled) {
        unawaited(_rt!.send(<String, Object?>{
          'type': 'text',
          'id': msgId, // ID pour éviter les duplications
          'text': text,
          'source_lang': _sourceLang,
          'target_lang': _targetLang,
          'ts': DateTime.now().toUtc().toIso8601String(),
        }));
      }

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

  Future<void> _loadSilentMode() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _silentMode = sp.getBool('silent_mode') ?? false;
  }

  Future<void> _saveSilentMode() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setBool('silent_mode', _silentMode);
  }

  void toggleSilentMode() {
    _silentMode = !_silentMode;
    _saveSilentMode();
    ref.notifyListeners();
  }

  String _detectLanguage(String text) {
    // Détecte si le texte contient des caractères chinois
    final RegExp chineseRegex = RegExp(r'[\u4e00-\u9fff]');
    if (chineseRegex.hasMatch(text)) {
      return 'zh';
    }
    return 'fr';
  }

  Future<void> _receiveRemote(String text, {String? sourceLang, String? targetLang, String? msgId}) async {
    // Vérifier si on a déjà ce message (éviter duplication)
    if (msgId != null) {
      final bool exists = state.any((m) => m.id == msgId);
      if (exists) {
        // C'est notre propre message qui revient en boucle, on l'ignore
        return;
      }
    }
    
    // Utiliser les métadonnées du sender si disponibles
    final String src = sourceLang ?? (text.contains(RegExp(r'[\u4e00-\u9fff]')) ? 'zh' : 'fr');
    // TOUJOURS traduire vers notre langue source (ce qu'on veut voir)
    // APK 001 (_sourceLang='fr') reçoit ZH → traduit en FR
    // APK 002 (_sourceLang='zh') reçoit FR → traduit en ZH
    final String target = _sourceLang;
    
    // Si le message est déjà dans notre langue, on l'affiche tel quel
    if (src == _sourceLang) {
      final ChatMessage replyMsg = ChatMessage(
        id: msgId ?? (DateTime.now().microsecondsSinceEpoch + 1).toString(),
        originalText: text,
        translatedText: text,
        isMe: false,
        time: DateTime.now().toUtc(),
      );
      state = <ChatMessage>[...state, replyMsg];
      await saveMessages();
      ref.notifyListeners();
      return;
    }
    
    // Sinon, traduire le message vers notre langue
    try {
      final TranslationResult res = await _repo.translate(
        text: text,
        sourceLang: src,
        targetLang: target, // TOUJOURS vers _sourceLang
        tone: _tone,
        wantPinyin: target == 'zh' ? _wantPinyin : false,
      );

      final ChatMessage replyMsg = ChatMessage(
        id: msgId ?? (DateTime.now().microsecondsSinceEpoch + 1).toString(),
        originalText: text, // Le texte original reçu (dans la langue de l'autre)
        translatedText: res.translation, // La traduction dans NOTRE langue
        isMe: false,
        time: DateTime.now().toUtc(),
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

  /// Reconnecter le service realtime
  void reconnect() {
    if (AppEnv.relayRoom.isEmpty) return;
    
    // Nettoyer l'ancienne connexion
    _rt?.disconnect();
    _rt?.dispose();
    _rt = null;
    
    // Créer et connecter un nouveau service
    _rt = RealtimeService(url: AppEnv.relayWsUrl, room: AppEnv.relayRoom);
    _rt!.connect();
    
    // Réécouter les messages
    _rt!.messages.listen((Map<String, dynamic> msg) {
      final String? kind = msg['type'] as String?;
      if (kind == 'text') {
        final String? text = msg['text'] as String?;
        final String? srcLang = msg['source_lang'] as String?;
        final String? tgtLang = msg['target_lang'] as String?;
        final String? msgId = msg['id'] as String?;
        if (text == null) return;
        _receiveRemote(text, sourceLang: srcLang, targetLang: tgtLang, msgId: msgId);
        unawaited(BadgeService.increment());
        try {
          _notif.showIncomingMessage(
            title: _sourceLang == 'fr' ? 'Nouveau message (ZH→FR)' : '新消息 (FR→ZH)',
            body: text,
            silent: _silentMode,
          );
        } catch (_) {}
      } else if (kind == 'attachment') {
        final String? url = msg['url'] as String?;
        final String? id = msg['id'] as String?;
        final String? mime = msg['mime'] as String?;
        final String? k = msg['kind'] as String?;
        if (url == null || id == null || mime == null || k == null) return;
        final AttachmentKind kindAtt = (k == 'video') ? AttachmentKind.video : AttachmentKind.image;
        final Attachment att = Attachment(
          id: id,
          kind: kindAtt,
          mimeType: mime,
          remoteUrl: url,
          createdAt: DateTime.now().toUtc(),
          status: AttachmentStatus.uploaded,
        );
        final ChatMessage m = ChatMessage(
          id: (DateTime.now().microsecondsSinceEpoch + 1).toString(),
          originalText: '',
          translatedText: '',
          isMe: false,
          time: DateTime.now().toUtc(),
          attachments: <Attachment>[att],
        );
        state = <ChatMessage>[...state, m];
        saveMessages();
        ref.notifyListeners();
        unawaited(BadgeService.increment());
        try {
          _notif.showIncomingMessage(
            title: _sourceLang == 'fr' ? 'Pièce jointe reçue' : '收到附件',
            body: mime,
            silent: _silentMode,
          );
        } catch (_) {}
      }
    });
    
    // Écouter le statut de connexion pour notifier l'UI
    _rt!.connectionStatus.listen((bool connected) {
      ref.notifyListeners();
    });
  }

  /// Démarrer l'enregistrement vocal
  Future<bool> startRecordingVoice() async {
    return await _audioRecorder.startRecording();
  }

  /// Arrêter l'enregistrement vocal et envoyer
  Future<void> stopRecordingVoice() async {
    final path = await _audioRecorder.stopRecording();
    if (path != null) {
      // Envoyer le fichier audio comme pièce jointe
      final AttachmentDraft? draft = await _picker.pickFile(path);
      if (draft != null) {
        await _sendAttachmentDraft(draft);
      }
    }
  }

  /// Envoyer une pièce jointe (utilitaire)
  Future<void> _sendAttachmentDraft(AttachmentDraft draft) async {
    final String attId = DateTime.now().microsecondsSinceEpoch.toString();
    final Attachment pending = Attachment(
      id: attId,
      kind: draft.kind,
      mimeType: draft.mimeType,
      localPath: draft.sourcePath,
      createdAt: DateTime.now().toUtc(),
      status: AttachmentStatus.uploading,
    );
    final ChatMessage msg = ChatMessage(
      id: (DateTime.now().microsecondsSinceEpoch + 1).toString(),
      originalText: '',
      translatedText: '',
      isMe: true,
      time: DateTime.now().toUtc(),
      attachments: <Attachment>[pending],
    );
    state = <ChatMessage>[...state, msg];
    ref.notifyListeners();

    _uploader.upload(draft).listen((UploadProgress p) async {
      final List<ChatMessage> updated = state.map((m) {
        if (m.id != msg.id) return m;
        final Attachment a = m.attachments.first.copyWith(
          status: (p.remoteUrl != null) ? AttachmentStatus.uploaded : AttachmentStatus.uploading,
        );
        return m.copyWith(attachments: <Attachment>[a]);
      }).toList(growable: false);
      state = updated;
      ref.notifyListeners();

      if (p.remoteUrl != null && _rt != null && _rt!.enabled) {
        unawaited(_rt!.send(<String, Object?>{
          'type': 'attachment',
          'id': attId,
          'kind': draft.kind.name,
          'mime': draft.mimeType,
          'url': p.remoteUrl,
          'ts': DateTime.now().toUtc().toIso8601String(),
        }));
        await saveMessages();
      }
    });
  }

  /// Prendre une photo avec la caméra et l'envoyer
  Future<void> pickAndSendCameraPhoto() async {
    final AttachmentDraft? draft = await _picker.pickCameraImage();
    if (draft != null) {
      await _sendAttachmentDraft(draft);
    }
  }

  /// Prendre une vidéo avec la caméra et l'envoyer
  Future<void> pickAndSendCameraVideo() async {
    final AttachmentDraft? draft = await _picker.pickCameraVideo();
    if (draft != null) {
      await _sendAttachmentDraft(draft);
    }
  }
}



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
import '../../../core/network/message_queue.dart';
import '../../../core/media/attachment_picker_service.dart';
import '../../../core/media/audio_recorder_service.dart';
import '../data/models/attachment.dart';
import '../../../core/network/upload/cloud_upload_service.dart';
import '../../../core/network/upload/upload_service.dart';
import '../data/models/photo_gallery_item.dart';
import '../data/photo_repository.dart';

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
  final MessageQueue _messageQueue = MessageQueue();
  final NotificationService _notif = NotificationService();
  final AttachmentPickerService _picker = AttachmentPickerService();
  late final UploadService _uploader = CloudUploadService(endpointBase: AppEnv.uploadBaseUrl);
  final PhotoRepository _photoRepo = PhotoRepository();
  final AudioRecorderService _audioRecorder = AudioRecorderService();
  StreamSubscription<bool>? _connectionSub;

  String get sourceLang => _sourceLang;
  String get targetLang => _targetLang;
  String get tone => _tone;
  bool get wantPinyin => _wantPinyin;
  bool get isSending => _isSending;
  String? get lastError => _lastError;
  bool get silentMode => _silentMode;
  bool get isConnected => _rt?.isConnected ?? false;
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
    // Load message queue
    _messageQueue.load();
    // Connect realtime relay if a room is present; URL may be provided at build or defaulted elsewhere
    if (AppEnv.relayRoom.isNotEmpty) {
      _rt = RealtimeService(url: AppEnv.relayWsUrl, room: AppEnv.relayRoom);
      _rt!.connect();
      
      // Listen to connection status changes
      _connectionSub = _rt!.connectionStatus.listen((bool isConnected) {
        if (isConnected) {
          print('[ChatController] ✅ Connected - processing queue...');
          _processQueue();
        } else {
          print('[ChatController] 🔴 Disconnected');
        }
        // Notifier l'UI du changement de statut de connexion
        ref.notifyListeners();
      });
      
      _rt!.messages.listen((Map<String, dynamic> msg) {
        final String? kind = msg['type'] as String?;
        if (kind == 'text') {
          final String? text = msg['text'] as String?;
          final String? srcLang = msg['source_lang'] as String?;
          final String? tgtLang = msg['target_lang'] as String?;
          if (text == null) return;
          _receiveRemote(text, sourceLang: srcLang, targetLang: tgtLang);
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
    
    // DÉTECTION AUTOMATIQUE DE LANGUE
    final String detectedLang = _detectLanguage(text);
    
    // Définir automatiquement source et target
    if (detectedLang == 'zh') {
      _sourceLang = 'zh';
      _targetLang = 'fr';
    } else {
      _sourceLang = 'fr';
      _targetLang = 'zh';
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
      // 1. Créer TON message original (ce que TU vois dans TA langue)
      final ChatMessage myMsg = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        originalText: text,
        translatedText: '', // Pas de traduction pour ton propre message
        isMe: true, // TON message
        time: DateTime.now().toUtc(),
        pinyin: null,
        notes: null,
      );
      state = <ChatMessage>[...state, myMsg];
      ref.notifyListeners();
      
      // 2. Broadcast to relay so the counterpart client receives it
      if (broadcast && _rt != null && _rt!.enabled) {
        unawaited(_rt!.send(<String, Object?>{
          'type': 'text',
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

  Future<void> _receiveRemote(String text, {String? sourceLang, String? targetLang}) async {
    // Use the metadata from the sender if available, otherwise fall back to assumptions
    final String src = sourceLang ?? _targetLang;
    final String target = targetLang ?? _sourceLang;
    
    // If the message is already in our language, display it without translation
    if (target == _sourceLang) {
      final ChatMessage replyMsg = ChatMessage(
        id: (DateTime.now().microsecondsSinceEpoch + 1).toString(),
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
    
    // Otherwise, translate the message
    try {
      final TranslationResult res = await _repo.translate(
        text: text,
        sourceLang: src,
        targetLang: _sourceLang,
        tone: _tone,
        wantPinyin: _sourceLang == 'zh' ? _wantPinyin : false,
      );

      final ChatMessage replyMsg = ChatMessage(
        id: (DateTime.now().microsecondsSinceEpoch + 1).toString(),
        originalText: text, // Le texte original reçu (dans la langue de l'autre)
        translatedText: res.translation, // La traduction dans TA langue
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

  /// Envoyer un message ou le mettre en queue si pas de connexion
  Future<void> _sendOrQueue(Map<String, Object?> message) async {
    if (_rt == null || !_rt!.enabled) return;
    
    final String queuedId = await _messageQueue.enqueue(message);
    print('[ChatController] 📝 Message queued (ID: $queuedId, ${_messageQueue.currentSize} pending)');
    
    final bool sent = await _rt!.send(message);
    
    if (sent) {
      await _messageQueue.remove(queuedId);
      print('[ChatController] ✅ Message $queuedId sent & removed from queue');
    } else {
      print('[ChatController] ❌ Message $queuedId failed, staying in queue for retry');
    }
  }

  /// Traiter la queue des messages en attente
  Future<void> _processQueue() async {
    final messages = _messageQueue.getAll();
    
    if (messages.isEmpty) {
      print('[ChatController] Queue empty');
      return;
    }
    
    print('[ChatController] Processing ${messages.length} queued messages...');
    
    for (final queuedMsg in messages) {
      if (queuedMsg.retryCount > 5) {
        print('[ChatController] Message ${queuedMsg.id} exceeded retry limit, removing');
        await _messageQueue.remove(queuedMsg.id);
        continue;
      }
      
      final bool sent = await _rt!.send(queuedMsg.message);
      
      if (sent) {
        print('[ChatController] ✅ Message ${queuedMsg.id} sent');
        await _messageQueue.remove(queuedMsg.id);
      } else {
        print('[ChatController] ❌ Message ${queuedMsg.id} failed, retry later');
        await _messageQueue.incrementRetry(queuedMsg.id);
      }
      
      await Future.delayed(const Duration(milliseconds: 200));
    }
    
    print('[ChatController] Queue processed (${_messageQueue.currentSize} remaining)');
  }
  
  /// Prendre une photo avec la caméra et l'envoyer
  Future<void> pickAndSendCameraPhoto() async {
    final AttachmentDraft? draft = await _picker.pickImageFromCamera();
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
    
    await saveMessages();
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

      if (p.remoteUrl != null || p.base64Data != null) {
        if (_rt != null && _rt!.enabled) {
          unawaited(_sendOrQueue(<String, Object?>{
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
        
        if (draft.kind == AttachmentKind.image) {
          try {
            final String photoUrl = p.base64Data ?? p.remoteUrl ?? draft.sourcePath ?? 'file://local';
            await _photoRepo.savePhoto(PhotoGalleryItem(
              id: attId,
              url: photoUrl,
              localPath: draft.sourcePath,
              timestamp: DateTime.now().toUtc(),
              isFromMe: true,
              status: PhotoStatus.cached,
            ));
          } catch (e) {
            print('[ChatController] Error saving photo to gallery: $e');
          }
        }
      }
    });
  }

  /// Prendre une vidéo avec la caméra et l'envoyer
  Future<void> pickAndSendCameraVideo() async {
    final AttachmentDraft? draft = await _picker.pickVideoFromCamera();
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
    
    await saveMessages();
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

      if (p.remoteUrl != null) {
        if (_rt != null && _rt!.enabled) {
          unawaited(_sendOrQueue(<String, Object?>{
            'type': 'attachment',
            'id': attId,
            'kind': draft.kind.name,
            'mime': draft.mimeType,
            'url': p.remoteUrl,
            'ts': DateTime.now().toUtc().toIso8601String(),
          }));
        }
        await saveMessages();
      }
    });
  }

  /// Forcer la reconnexion au relay
  Future<void> reconnect() async {
    print('[ChatController] 🔄 Manual reconnect requested');
    
    if (_rt == null) {
      print('[ChatController] ❌ No relay service configured');
      return;
    }
    
    await _rt!.dispose();
    
    _rt = RealtimeService(url: AppEnv.relayWsUrl, room: AppEnv.relayRoom);
    
    await _rt!.connect();
    
    _connectionSub?.cancel();
    _connectionSub = _rt!.connectionStatus.listen((bool isConnected) {
      if (isConnected) {
        print('[ChatController] ✅ Connected - processing queue...');
        _processQueue();
      } else {
        print('[ChatController] 🔴 Disconnected');
      }
      ref.notifyListeners();
    });
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_rt!.isConnected) {
      print('[ChatController] 🔄 Processing queue after manual reconnect...');
      await _processQueue();
    }
    
    print('[ChatController] ✅ Reconnect complete');
    ref.notifyListeners();
  }

  /// Démarrer l'enregistrement vocal
  Future<bool> startRecordingVoice() async {
    return await _audioRecorder.startRecording();
  }

  /// Arrêter l'enregistrement vocal et envoyer le message
  Future<void> stopRecordingVoice() async {
    final audioPath = await _audioRecorder.stopRecording();
    
    if (audioPath == null || audioPath.isEmpty) {
      print('[ChatController] ❌ No audio recorded');
      return;
    }

    final attId = DateTime.now().microsecondsSinceEpoch.toString();
    final Attachment audioAtt = Attachment(
      id: attId,
      kind: AttachmentKind.audio,
      mimeType: 'audio/m4a',
      localPath: audioPath,
      createdAt: DateTime.now().toUtc(),
      status: AttachmentStatus.uploading,
    );
    
    final ChatMessage msg = ChatMessage(
      id: (DateTime.now().microsecondsSinceEpoch + 1).toString(),
      originalText: '',
      translatedText: '',
      isMe: true,
      time: DateTime.now().toUtc(),
      attachments: <Attachment>[audioAtt],
    );
    
    state = <ChatMessage>[...state, msg];
    
    await saveMessages();
    ref.notifyListeners();
    
    final AudioAttachmentDraft draft = AudioAttachmentDraft(
      kind: AttachmentKind.audio,
      sourcePath: audioPath,
      mimeType: 'audio/m4a',
    );
    
    _uploader.uploadAudio(draft).listen((UploadProgress p) async {
      final List<ChatMessage> updated = state.map((m) {
        if (m.id != msg.id) return m;
        final Attachment a = m.attachments.first.copyWith(
          status: (p.remoteUrl != null || p.base64Data != null) 
              ? AttachmentStatus.uploaded 
              : AttachmentStatus.uploading,
        );
        return m.copyWith(attachments: <Attachment>[a]);
      }).toList(growable: false);
      state = updated;
      ref.notifyListeners();

      if (p.remoteUrl != null || p.base64Data != null) {
        if (_rt != null && _rt!.enabled) {
          unawaited(_sendOrQueue(<String, Object?>{
            'type': 'attachment',
            'id': attId,
            'kind': 'audio',
            'mime': 'audio/m4a',
            'url': p.remoteUrl,
            if (p.base64Data != null) 'base64': p.base64Data,
            'ts': DateTime.now().toUtc().toIso8601String(),
          }));
        }
        await saveMessages();
      }
    });
  }

  /// Annuler l'enregistrement vocal en cours
  Future<void> cancelRecordingVoice() async {
    await _audioRecorder.cancelRecording();
  }
}



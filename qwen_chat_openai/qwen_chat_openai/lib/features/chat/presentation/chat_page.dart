import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chat_controller.dart';
import 'widgets/composer_bar.dart';
import 'widgets/message_bubble.dart';
import 'widgets/attachment_bubble.dart';
import '../data/models/attachment.dart';
import '../../../core/network/badge_service.dart';
import '../../../core/network/notification_service.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _listCtrl = ScrollController();
  int _previousMessageCount = 0;

  @override
  void initState() {
    super.initState();
    Future<void>(() async {
      await ref.read(chatControllerProvider.notifier).loadMessages();
      // Auto-scroll to bottom on first open, after messages are loaded
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_listCtrl.hasClients) {
          _listCtrl.jumpTo(_listCtrl.position.maxScrollExtent);
        }
      });
    });
    // Opening chat clears the unread badge AND permanent notification
    Future<void>(() async {
      await BadgeService.clear();
      // Clear the permanent notification
      final notif = NotificationService();
      await notif.clearSummaryNotification();
    });
    
    // Auto-scroll listener pour les messages reçus via WebSocket
    _listCtrl.addListener(() {
      // Quand scroll atteint le bas (message lu) → clear badge
      if (_listCtrl.hasClients && 
          _listCtrl.position.pixels >= _listCtrl.position.maxScrollExtent - 100) {
        BadgeService.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(chatControllerProvider.notifier);
    final messages = ref.watch(chatControllerProvider);
    
    // Auto-scroll quand un nouveau message arrive (envoi ou réception WebSocket)
    if (messages.length > _previousMessageCount) {
      _previousMessageCount = messages.length;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_listCtrl.hasClients && mounted) {
          _listCtrl.animateTo(
            _listCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }

    // Badge count pour afficher le nombre de messages non lus
    final int badgeCount = ref.watch(badgeCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('XiaoXin'),
        actions: <Widget>[
          // Badge rouge avec compteur de messages non lus
          Stack(
            children: [
              IconButton(
                tooltip: controller.silentMode ? 'Mode normal' : 'Mode silencieux',
                onPressed: controller.toggleSilentMode,
                icon: Icon(controller.silentMode ? Icons.notifications_off : Icons.notifications),
              ),
              if (badgeCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // Bouton swap supprimé - détection automatique de langue
        ],
      ),
      body: Column(
        children: <Widget>[
          if (controller.lastError != null)
            MaterialBanner(
              content: Text(controller.lastError!),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                    // Clear the error explicitly
                    ref.read(chatControllerProvider.notifier).clearError();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              controller: _listCtrl,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: messages.length,
              itemBuilder: (BuildContext context, int index) {
                final m = messages[index];
                if (m.attachments.isNotEmpty) {
                  // Display first attachment for MVP (can extend to list/column)
                  final Attachment a = m.attachments.first;
                  return AttachmentBubble(attachment: a, isMe: m.isMe, time: m.time);
                }
                return MessageBubble(
                  isMe: m.isMe,
                  original: m.originalText,
                  translation: m.translatedText,
                  pinyin: m.pinyin,
                  notes: m.notes,
                  time: m.time,
                );
              },
            ),
              ),
          ComposerBar(
            controller: _textCtrl,
            enabled: true,
            hintText: controller.sourceLang == 'fr'
                ? 'Écrire en français…'
                : '用中文输入…',
                onPickAttachment: () async {
                  await ref.read(chatControllerProvider.notifier).pickAndSendAttachment();
                },
            onSend: () async {
              final text = _textCtrl.text;
              _textCtrl.clear();
              await ref.read(chatControllerProvider.notifier).send(text);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_listCtrl.hasClients) {
                  _listCtrl.animateTo(
                    _listCtrl.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  );
                }
              });
            },
          ),
        ],
      ),
    );
  }
}



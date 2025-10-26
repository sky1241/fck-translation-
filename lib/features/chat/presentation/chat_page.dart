import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chat_controller.dart';
import 'widgets/composer_bar.dart';
import 'widgets/message_bubble.dart';
import 'widgets/attachment_bubble.dart';
import '../data/models/attachment.dart';
import '../../../core/network/badge_service.dart';
import '../../../core/network/notification_service.dart';
import '../../../core/env/app_env.dart';
import 'photo_gallery_page.dart';

class ChatPage extends ConsumerStatefulWidget {
  ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _listCtrl = ScrollController();

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
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(chatControllerProvider.notifier);
    final messages = ref.watch(chatControllerProvider);
    
    // Surveiller le statut de connexion
    final isConnected = controller.isConnected;
    print('[ChatPage] BUILD - isConnected=$isConnected');

    final String title = 'XiaoXin ${AppEnv.appVersion}';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title),
            const SizedBox(width: 8),
            // Indicateur de connexion au serveur
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isConnected ? Colors.green : Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          // Bouton Galerie Photo (Cœur surélevé)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              color: Colors.pink.shade400,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<Widget>(builder: (_) => const PhotoGalleryPage()),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          // Bouton Notifications (Cloche surélevée)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              color: controller.silentMode ? Colors.grey.shade600 : Colors.teal.shade400,
              child: InkWell(
                onTap: controller.toggleSilentMode,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    controller.silentMode ? Icons.notifications_off : Icons.notifications,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          // Indicateur de connexion (GROS bouton vert/rouge)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              color: isConnected ? Colors.green.shade600 : Colors.red.shade600,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isConnected ? Icons.check_circle : Icons.error,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isConnected ? 'EN LIGNE' : 'HORS LIGNE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
          // Banderole de reconnexion quand hors ligne
          if (!isConnected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.orange.shade100,
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hors ligne - Envoyez un message pour vous reconnecter',
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
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

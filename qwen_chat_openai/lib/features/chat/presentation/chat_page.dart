import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chat_controller.dart';
import 'widgets/composer_bar.dart';
import 'widgets/message_bubble.dart';
import 'widgets/attachment_bubble.dart';
import '../data/models/attachment.dart';
import '../../../core/network/badge_service.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _listCtrl = ScrollController();

  IconData _getToneIcon(String tone) {
    switch (tone) {
      case 'affectionate':
        return Icons.favorite;
      case 'intimate':
        return Icons.favorite_border;
      case 'casual':
        return Icons.chat_bubble_outline;
      default:
        return Icons.chat;
    }
  }

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
    // Opening chat clears the unread badge
    Future<void>(() async { await BadgeService.clear(); });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(chatControllerProvider.notifier);
    final messages = ref.watch(chatControllerProvider);

    final String title =
        controller.sourceLang == 'fr' ? 'FR → ZH' : 'ZH → FR';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          // Tone selector
          PopupMenuButton<String>(
            tooltip: 'Ton: ${controller.tone}',
            icon: Icon(_getToneIcon(controller.tone)),
            onSelected: (String newTone) {
              controller.setTone(newTone);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'affectionate',
                child: Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.pink),
                    SizedBox(width: 8),
                    Text('Affectueux 💕'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'intimate',
                child: Row(
                  children: [
                    Icon(Icons.favorite_border, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Intime 🔥'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'casual',
                child: Row(
                  children: [
                    Icon(Icons.chat_bubble_outline, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Décontracté 😊'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            tooltip: 'Swap',
            onPressed: controller.swapDirection,
            icon: const Icon(Icons.swap_horiz),
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



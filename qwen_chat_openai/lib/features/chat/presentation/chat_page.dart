import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chat_controller.dart';
import 'widgets/composer_bar.dart';
import 'widgets/message_bubble.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _textCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future<void>(() async {
      await ref.read(chatControllerProvider.notifier).loadMessages();
    });
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
          IconButton(
            tooltip: 'Swap',
            onPressed: controller.swapDirection,
            icon: const Icon(Icons.swap_horiz),
          ),
          IconButton(
            tooltip: 'Effacer',
            onPressed: controller.clear,
            icon: const Icon(Icons.delete_outline),
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
                  onPressed: () => ref
                      .read(chatControllerProvider.notifier)
                      .swapDirection(),
                  child: const Text('OK'),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: <Widget>[
                DropdownButton<String>(
                  value: controller.tone,
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem(value: 'casual', child: Text('Casual')),
                    DropdownMenuItem(
                        value: 'affectionate', child: Text('Affectionate')),
                    DropdownMenuItem(
                        value: 'business', child: Text('Business')),
                  ],
                  onChanged: (String? v) {
                    if (v != null) {
                      ref.read(chatControllerProvider.notifier).setTone(v);
                    }
                  },
                ),
                const SizedBox(width: 12),
                if (controller.targetLang == 'zh')
                  Row(
                    children: <Widget>[
                      const Text('Pinyin'),
                      Switch(
                        value: controller.wantPinyin,
                        onChanged: (_) => ref
                            .read(chatControllerProvider.notifier)
                            .togglePinyin(),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: messages.length,
              itemBuilder: (BuildContext context, int index) {
                final m = messages[index];
                return MessageBubble(
                  isMe: m.isMe,
                  original: m.originalText,
                  translation: m.translatedText,
                  pinyin: m.pinyin,
                  notes: m.notes,
                );
              },
            ),
          ),
          ComposerBar(
            controller: _textCtrl,
            enabled: !controller.isSending,
            hintText: controller.sourceLang == 'fr'
                ? 'Écrire en français…'
                : '用中文输入…',
            onSend: () async {
              final text = _textCtrl.text;
              _textCtrl.clear();
              await ref.read(chatControllerProvider.notifier).send(text);
            },
          ),
        ],
      ),
    );
  }
}



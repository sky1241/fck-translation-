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
            // Point vert/rouge + status texte
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isConnected ? Colors.green : Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              isConnected ? 'online' : 'offline',
              style: TextStyle(
                fontSize: 10,
                color: isConnected ? Colors.green.shade300 : Colors.red.shade300,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          // AppBar responsive - adapte la taille selon l'écran
          ..._buildResponsiveActions(context, controller, isConnected),
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

  /// Construire les boutons de l'AppBar de manière responsive
  List<Widget> _buildResponsiveActions(BuildContext context, ChatController controller, bool isConnected) {
    // Taille adaptative selon l'écran
    final double screenWidth = MediaQuery.of(context).size.width;
    final double buttonSize = screenWidth < 360 ? 20.0 : 24.0;
    final double padding = screenWidth < 360 ? 6.0 : 8.0;
    final double horizontalPadding = screenWidth < 360 ? 2.0 : 4.0;

    return [
      // Bouton Galerie Photo (❤️)
      Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: padding),
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
              padding: EdgeInsets.all(padding),
              child: Icon(
                Icons.favorite,
                color: Colors.white,
                size: buttonSize,
              ),
            ),
          ),
        ),
      ),
      // Bouton CAMÉRA (📷) - Prendre photo/vidéo
      Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: padding),
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          color: Colors.blue.shade600,
          child: InkWell(
            onTap: () async {
              // Menu: Photo ou Vidéo (texte adapté selon la version)
              final bool isChinese = AppEnv.defaultDirection == 'zh2fr';
              showModalBottomSheet(
                context: context,
                builder: (context) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.camera_alt, color: Colors.blue),
                        title: Text(isChinese ? '拍照' : 'Prendre une photo'),
                        onTap: () async {
                          Navigator.pop(context);
                          await ref.read(chatControllerProvider.notifier).pickAndSendCameraPhoto();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.videocam, color: Colors.red),
                        title: Text(isChinese ? '录制视频' : 'Enregistrer une vidéo'),
                        onTap: () async {
                          Navigator.pop(context);
                          await ref.read(chatControllerProvider.notifier).pickAndSendCameraVideo();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.photo_library, color: Colors.green),
                        title: Text(isChinese ? '从相册选择' : 'Choisir depuis la galerie'),
                        onTap: () async {
                          Navigator.pop(context);
                          await ref.read(chatControllerProvider.notifier).pickAndSendAttachment();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(padding),
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: buttonSize,
              ),
            ),
          ),
        ),
      ),
      // Bouton Notifications (🔔)
      Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: padding),
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          color: controller.silentMode ? Colors.grey.shade600 : Colors.teal.shade400,
          child: InkWell(
            onTap: controller.toggleSilentMode,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(padding),
              child: Icon(
                controller.silentMode ? Icons.notifications_off : Icons.notifications,
                color: Colors.white,
                size: buttonSize,
              ),
            ),
          ),
        ),
      ),
      // Bouton Reconnexion (🔄) - Visible seulement si déconnecté
      if (!isConnected)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: padding),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            color: Colors.orange.shade600,
            child: InkWell(
              onTap: () {
                controller.reconnect();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.all(padding),
                child: Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: buttonSize,
                ),
              ),
            ),
          ),
        ),
    ];
  }
}

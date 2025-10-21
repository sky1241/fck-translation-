import 'package:flutter/material.dart';
import 'dart:io';
import '../../data/models/attachment.dart';
import 'base64_image_widget.dart';

class AttachmentBubble extends StatelessWidget {
  const AttachmentBubble({super.key, required this.attachment, required this.isMe, this.time});

  final Attachment attachment;
  final bool isMe;
  final DateTime? time;

  @override
  Widget build(BuildContext context) {
    final Color bubble = isMe ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceContainerHighest;
    final BorderRadius radius = BorderRadius.only(
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
      bottomLeft: Radius.circular(isMe ? 12 : 2),
      bottomRight: Radius.circular(isMe ? 2 : 12),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: bubble, borderRadius: radius),
      constraints: const BoxConstraints(maxWidth: 320),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildContent(context),
          if (time != null) ...<Widget>[
            const SizedBox(height: 6),
            const SizedBox(height: 2),
            Text(
              _formatTime(time!),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (attachment.kind == AttachmentKind.image) {
      final String? url = attachment.remoteUrl;
      final String? local = attachment.localPath;
      
      return AspectRatio(
        aspectRatio: (attachment.width != null && attachment.height != null && attachment.height! > 0)
            ? (attachment.width! / attachment.height!)
            : 4 / 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: local != null && File(local).existsSync()
              ? Image.file(File(local), fit: BoxFit.cover)
              : url != null
                  ? Base64ImageWidget(
                      imageSource: url,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.black12,
                      alignment: Alignment.center,
                      child: Icon(Icons.image, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
        ),
      );
    }
    // Video placeholder
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.videocam),
        const SizedBox(width: 8),
        Text(attachment.mimeType, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

String _formatTime(DateTime t) {
  final String hh = t.hour.toString().padLeft(2, '0');
  final String mm = t.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}



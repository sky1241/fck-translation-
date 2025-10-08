import 'package:flutter/material.dart';
import '../../data/models/attachment.dart';

class AttachmentBubble extends StatelessWidget {
  const AttachmentBubble({super.key, required this.attachment, required this.isMe});

  final Attachment attachment;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final Color bubble = isMe ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceVariant;
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
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (attachment.kind == AttachmentKind.image) {
      final String? url = attachment.remoteUrl;
      final ImageProvider? image = url != null ? NetworkImage(url) : null;
      return AspectRatio(
        aspectRatio: (attachment.width != null && attachment.height != null && attachment.height! > 0)
            ? (attachment.width! / attachment.height!)
            : 4 / 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: image != null
              ? Image(image: image, fit: BoxFit.cover)
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



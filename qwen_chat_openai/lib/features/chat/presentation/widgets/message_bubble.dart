import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.isMe,
    required this.original,
    required this.translation,
    this.pinyin,
    this.notes,
  });

  final bool isMe;
  final String original;
  final String translation;
  final String? pinyin;
  final String? notes;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Color bubbleColor =
        isMe ? cs.primaryContainer : cs.surfaceContainerHighest;
    final Alignment align = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final CrossAxisAlignment cross =
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: cross,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              original,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 4),
            Text(
              translation,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (pinyin != null && pinyin!.isNotEmpty) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                pinyin!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (notes != null && notes!.isNotEmpty) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                notes!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}



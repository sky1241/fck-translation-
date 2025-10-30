import 'package:flutter/material.dart';

class ComposerBar extends StatelessWidget {
  const ComposerBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.enabled,
    required this.hintText,
    this.onPickAttachment,
    this.onRecordVoice,
    this.isRecordingVoice = false,
    this.recordingDuration = 0,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;
  final String hintText;
  final VoidCallback? onPickAttachment;
  final Future<bool> Function()? onRecordVoice;
  final bool isRecordingVoice;
  final int recordingDuration;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: Row(
          children: <Widget>[
            // Bouton Microphone (Toujours visible)
            GestureDetector(
              onLongPressStart: (details) async {
                if (onRecordVoice != null && enabled && !isRecordingVoice) {
                  await onRecordVoice!();
                }
              },
              onLongPressEnd: (details) async {
                if (onRecordVoice != null && enabled && isRecordingVoice) {
                  await onRecordVoice!();
                }
              },
              child: Material(
                color: isRecordingVoice 
                    ? Colors.red.shade600 
                    : Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.mic,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
            Expanded(
              child: isRecordingVoice
                  ? Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mic, color: Colors.red.shade600, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _formatDuration(recordingDuration),
                            style: TextStyle(
                              color: Colors.red.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : TextField(
                      controller: controller,
                      enabled: enabled,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: hintText,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (BuildContext context, TextEditingValue value, _) {
                final bool canSend =
                    enabled && value.text.trim().isNotEmpty;
                return ElevatedButton.icon(
                  onPressed: canSend ? onSend : null,
                  icon: const Icon(Icons.send),
                  label: const Text('Envoyer'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_controller.dart';
import 'chat_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguageSetupPage extends ConsumerWidget {
  const LanguageSetupPage({super.key});

  static const String _directionKey = 'chat_direction'; // 'fr2zh' | 'zh2fr'

  Future<void> _select(
    BuildContext context,
    WidgetRef ref, {
    required String source,
    required String target,
    required String store,
  }) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString(_directionKey, store);
    ref.read(chatControllerProvider.notifier).setDirection(source, target);
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<Widget>(builder: (_) => ChatPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choisir la direction')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _select(
                context,
                ref,
                source: 'fr',
                target: 'zh',
                store: 'fr2zh',
              ),
              child: const Text('FR → ZH (Chinois Simplifié)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _select(
                context,
                ref,
                source: 'zh',
                target: 'fr',
                store: 'zh2fr',
              ),
              child: const Text('ZH → FR (Français)'),
            ),
          ],
        ),
      ),
    );
  }
}



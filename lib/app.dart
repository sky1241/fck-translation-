import 'package:flutter/material.dart';

import 'features/chat/presentation/chat_page.dart';
import 'features/chat/presentation/language_setup_page.dart';
import 'core/env/app_env.dart';
import 'features/chat/presentation/chat_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FR ↔ ZH Chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const _Startup(),
    );
  }
}

class _Startup extends ConsumerStatefulWidget {
  const _Startup();

  @override
  ConsumerState<_Startup> createState() => _StartupState();
}

class _StartupState extends ConsumerState<_Startup> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String? dir = sp.getString('chat_direction');
    if (!mounted) return;
    if (dir == null) {
      // If compile-time default is set, apply it and skip the setup page
      if (AppEnv.defaultDirection == 'fr2zh' || AppEnv.defaultDirection == 'zh2fr') {
        final bool fr2zh = AppEnv.defaultDirection == 'fr2zh';
        await sp.setString('chat_direction', fr2zh ? 'fr2zh' : 'zh2fr');
        final controller = ref.read(chatControllerProvider.notifier);
        controller.setDirection(fr2zh ? 'fr' : 'zh', fr2zh ? 'zh' : 'fr');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<Widget>(builder: (_) => const ChatPage()),
        );
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<Widget>(builder: (_) => const LanguageSetupPage()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<Widget>(builder: (_) => const ChatPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}



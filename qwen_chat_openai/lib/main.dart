import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/network/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ensure notifications permission/init on startup (Android 13+ requests as needed)
  final NotificationService notif = NotificationService();
  try {
    await notif.initialize();
  } catch (_) {
    // Do not block startup if notifications init fails
  }
  runApp(const ProviderScope(child: App()));
}

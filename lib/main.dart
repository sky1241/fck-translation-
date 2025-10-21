import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/network/notification_service.dart';
import 'core/env/app_env.dart';
import 'core/permissions/permission_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Print configuration for debugging
  AppEnv.printConfig();
  
  // ✅ IMPORTANT: Demander les permissions au démarrage
  print('🔐 Requesting permissions...');
  try {
    await PermissionService.requestAllPermissions();
  } catch (e) {
    print('⚠️ Error requesting permissions: $e');
    // Ne pas bloquer le démarrage
  }
  
  // Ensure notifications permission/init on startup (Android 13+ requests as needed)
  final NotificationService notif = NotificationService();
  try {
    await notif.initialize();
  } catch (_) {
    // Do not block startup if notifications init fails
  }
  runApp(const ProviderScope(child: App()));
}

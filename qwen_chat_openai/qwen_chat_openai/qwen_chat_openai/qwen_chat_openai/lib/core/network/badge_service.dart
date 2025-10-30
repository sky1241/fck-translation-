import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb, debugPrint;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider pour rendre le badge count réactif dans l'UI
final badgeCountProvider = Provider<int>((ref) => BadgeService.currentCount);

class BadgeService {
  BadgeService._();

  static const MethodChannel _channel = MethodChannel('com.example.qwen_chat_openai/badge');
  static int _unreadCount = 0;
  static ProviderContainer? _container;
  
  static void setContainer(ProviderContainer container) {
    _container = container;
  }

  static int get currentCount => _unreadCount;

  static Future<void> clear() async {
    _unreadCount = 0;
    // Update provider pour UI réactive
    if (_container != null) {
      _container!.invalidate(badgeCountProvider);
    }
    // Clear visual badge on app icon using native ShortcutBadger
    try {
      if (kDebugMode) debugPrint('[BadgeService] Clearing badge via native plugin');
      final bool? success = await _channel.invokeMethod<bool>('removeBadge');
      if (kDebugMode) debugPrint('[BadgeService] Badge clear result: $success');
    } catch (e) {
      if (kDebugMode) debugPrint('[BadgeService] Error clearing badge: $e');
    }
  }

  static Future<void> increment() async {
    _unreadCount = (_unreadCount + 1).clamp(0, 9999);
    // Update provider pour UI réactive
    if (_container != null) {
      _container!.invalidate(badgeCountProvider);
    }
    if (kDebugMode) debugPrint('[BadgeService] Incrementing badge to $_unreadCount via native plugin');
    // Update visual badge on app icon using native ShortcutBadger
    try {
      final bool? success = await _channel.invokeMethod<bool>('setBadge', {'count': _unreadCount});
      if (kDebugMode) debugPrint('[BadgeService] Badge set to $_unreadCount, result: $success');
    } catch (e) {
      if (kDebugMode) debugPrint('[BadgeService] Error setting badge: $e');
    }
  }

  static bool get canUseBadges {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }
}



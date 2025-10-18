import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

class BadgeService {
  BadgeService._();

  static int _unreadCount = 0;

  static int get currentCount => _unreadCount;

  static Future<void> clear() async {
    _unreadCount = 0;
    // Badge cleared via notification count in NotificationService
  }

  static Future<void> increment() async {
    _unreadCount = (_unreadCount + 1).clamp(0, 9999);
    // Badge updated via notification count in NotificationService
  }

  static bool get canUseBadges {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }
}



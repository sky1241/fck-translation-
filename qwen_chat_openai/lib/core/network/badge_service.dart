import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
class BadgeService {
  BadgeService._();

  static int _unreadCount = 0;

  static int get currentCount => _unreadCount;

  static Future<void> clear() async {
    _unreadCount = 0;
    // No-op for now: plugin removed; keep internal counter only
  }

  static Future<void> increment() async {
    _unreadCount = (_unreadCount + 1).clamp(0, 9999);
    // No-op for now: plugin removed; keep internal counter only
  }

  static bool _canUseBadges() {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }
}



import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_app_badger/flutter_app_badger.dart';
class BadgeService {
  BadgeService._();

  static int _unreadCount = 0;

  static int get currentCount => _unreadCount;

  static Future<void> clear() async {
    _unreadCount = 0;
    if (_canUseBadges()) {
      try {
        // Older plugin versions expose void-returning APIs; call without await
        FlutterAppBadger.removeBadge();
      } catch (_) {}
    }
  }

  static Future<void> increment() async {
    _unreadCount = (_unreadCount + 1).clamp(0, 9999);
    if (_canUseBadges()) {
      try {
        FlutterAppBadger.updateBadgeCount(_unreadCount);
      } catch (_) {}
    }
  }

  static bool _canUseBadges() {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }
}



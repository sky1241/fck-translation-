import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_app_badger/flutter_app_badger.dart';

class BadgeService {
  BadgeService._();

  static int _unreadCount = 0;

  static Future<void> clear() async {
    _unreadCount = 0;
    if (_canUseBadges()) {
      final bool supported = await FlutterAppBadger.isAppBadgeSupported();
      if (supported) {
        try {
          await FlutterAppBadger.removeBadge();
        } catch (_) {}
      }
    }
  }

  static Future<void> increment() async {
    _unreadCount = (_unreadCount + 1).clamp(0, 9999);
    if (_canUseBadges()) {
      final bool supported = await FlutterAppBadger.isAppBadgeSupported();
      if (supported) {
        try {
          await FlutterAppBadger.updateBadgeCount(_unreadCount);
        } catch (_) {}
      }
    }
  }

  static bool _canUseBadges() {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }
}



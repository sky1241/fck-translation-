class BadgeService {
  BadgeService._();

  static int _unreadCount = 0;

  static int get currentCount => _unreadCount;

  static Future<void> clear() async {
    _unreadCount = 0;
    // No-op for now (badge plugin disabled on Android build for stability)
  }

  static Future<void> increment() async {
    _unreadCount = (_unreadCount + 1).clamp(0, 9999);
    // No-op for now
  }
}



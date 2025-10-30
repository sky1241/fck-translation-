import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'badge_service.dart';

class NotificationService {
  NotificationService() : _fln = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _fln;
  static const int _summaryNotificationId = 999999; // ID pour la notification permanente

  Future<void> initialize() async {
    // Use app icon (mipmap) for notifications - most reliable approach
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings init = InitializationSettings(android: androidInit);
    try {
      await _fln.initialize(init);
      
      // Create notification channel explicitly with sound enabled (Android 8.0+)
      // IMPORTANT: Android caches channel settings, so changing these after creation won't work
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'unread_messages_v4', // v4: Fixed to always have sound enabled by default
        'Messages non lus',
        description: 'Notifications des messages non lus avec son',
        importance: Importance.max, // MAX importance for sound + popup
        playSound: true,
        enableVibration: true,
        showBadge: true,
        enableLights: true,
      );
      
      await _fln
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      
      if (kDebugMode) debugPrint('[NotificationService] ✅ Channel created: unread_messages_v4 (sound enabled)');
    } catch (e) {
      if (kDebugMode) debugPrint('[NotificationService] ❌ Error initializing: $e');
      // Swallow initialization errors to avoid blocking app startup
    }
  }

  Future<void> showIncomingMessage({
    required String title,
    required String body,
    bool silent = false,
  }) async {
    // Increment badge first (in-memory counter)
    await BadgeService.increment();
    final int count = BadgeService.currentCount;
    
    // Show persistent notification with unread count
    try {
      final String summaryTitle = count == 1 ? '1 message non lu' : '$count messages non lus';
      
      // Note: Android caches channel settings, so playSound/enableVibration here won't override channel settings
      // To make silent mode work, we use onlyAlertOnce: true which prevents re-alerting
      final AndroidNotificationDetails summaryAndroid = AndroidNotificationDetails(
        'unread_messages_v4', // Must match channel ID created in initialize()
        'Messages non lus',
        channelDescription: 'Notifications des messages non lus avec son',
        importance: Importance.max, // Always MAX (channel setting takes precedence anyway)
        priority: Priority.high,
        ongoing: true, // Persistent notification
        autoCancel: false,
        number: count,
        showWhen: false,
        onlyAlertOnce: silent, // If silent=true, only alert once (no sound/vibration on updates)
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      );
      final NotificationDetails summaryDetails = NotificationDetails(android: summaryAndroid);
      
      // Note: showSilently() requires flutter_local_notifications >= 18.0.0
      // For now, we use show() with onlyAlertOnce for silent mode
      if (silent) {
        if (kDebugMode) debugPrint('[NotificationService] 🔇 Showing notification (silent mode - update only)');
      } else {
        if (kDebugMode) debugPrint('[NotificationService] 🔔 Showing notification WITH SOUND (count: $count)');
      }
      
      // Always show with show() (silent mode is achieved by using onlyAlertOnce which doesn't re-alert)
      await _fln.show(_summaryNotificationId, summaryTitle, 'Ouvrez XiaoXin002', summaryDetails);
    } catch (e) {
      if (kDebugMode) debugPrint('[NotificationService] ❌ Error showing summary notification: $e');
    }
  }

  Future<void> clearSummaryNotification() async {
    // Supprimer la notification permanente quand on ouvre le chat
    try {
      await _fln.cancel(_summaryNotificationId);
    } catch (_) {
      // Ignore
    }
  }
}



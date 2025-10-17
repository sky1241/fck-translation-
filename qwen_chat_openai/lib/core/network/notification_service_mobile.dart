import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'unread_messages_v2', // Changed ID to force new channel creation
        'Messages non lus',
        description: 'Notifications des messages non lus',
        importance: Importance.high, // HIGH importance for sound
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );
      
      await _fln
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    } catch (_) {
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
      final AndroidNotificationDetails summaryAndroid = AndroidNotificationDetails(
        'unread_messages_v2', // Must match channel ID created in initialize()
        'Messages non lus',
        channelDescription: 'Notifications des messages non lus',
        importance: Importance.high, // HIGH importance for sound
        priority: Priority.high,
        ongoing: true, // Persistent notification
        autoCancel: false,
        number: count,
        showWhen: false,
        playSound: !silent,
        enableVibration: !silent,
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      );
      final NotificationDetails summaryDetails = NotificationDetails(android: summaryAndroid);
      await _fln.show(_summaryNotificationId, summaryTitle, 'Ouvrez XiaoXin002', summaryDetails);
    } catch (e) {
      print('[NotificationService] Error showing summary notification: $e');
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



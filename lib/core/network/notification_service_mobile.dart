import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'badge_service.dart';

class NotificationService {
  NotificationService() : _fln = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _fln;

  Future<void> initialize() async {
    // Use a dedicated small icon in drawable for notifications
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('ic_stat_notification');
    const InitializationSettings init = InitializationSettings(android: androidInit);
    try {
      await _fln.initialize(init);
    } catch (_) {
      // Swallow initialization errors to avoid blocking app startup
    }
  }

  Future<void> showIncomingMessage({required String title, required String body}) async {
    // Increment badge first so we can reflect count in notification number where supported
    await BadgeService.increment();

    final int count = BadgeService.currentCount;
    final AndroidNotificationDetails android = AndroidNotificationDetails(
      'incoming_messages',
      'Incoming Messages',
      channelDescription: 'Notifications for new incoming chat messages',
      number: count, // Shown as badge count on supported launchers
    );
    final NotificationDetails details = NotificationDetails(android: android);
    await _fln.show(DateTime.now().millisecondsSinceEpoch ~/ 1000, title, body, details);
  }
}



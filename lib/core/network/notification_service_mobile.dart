import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'badge_service.dart';

class NotificationService {
  NotificationService() : _fln = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _fln;

  Future<void> initialize() async {
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('ic_launcher');
    const InitializationSettings init = InitializationSettings(android: androidInit);
    await _fln.initialize(init);
  }

  Future<void> showIncomingMessage({required String title, required String body}) async {
    // Increment badge first so we can reflect count in notification number where supported
    await BadgeService.increment();

    final int count = BadgeService.currentCount;
    final AndroidNotificationDetails android = AndroidNotificationDetails(
      'incoming_messages',
      'Incoming Messages',
      channelDescription: 'Notifications for new incoming chat messages',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      channelShowBadge: true,
      number: count, // Shown as badge count on supported launchers
    );
    final NotificationDetails details = NotificationDetails(android: android);
    await _fln.show(DateTime.now().millisecondsSinceEpoch ~/ 1000, title, body, details);
  }
}



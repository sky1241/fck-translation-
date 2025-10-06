import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService() : _fln = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _fln;

  Future<void> initialize() async {
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('ic_launcher');
    const InitializationSettings init = InitializationSettings(android: androidInit);
    await _fln.initialize(init);

    // Android 13+ POST_NOTIFICATIONS permission is handled by the plugin if needed
  }

  Future<void> showIncomingMessage({required String title, required String body}) async {
    const AndroidNotificationDetails android = AndroidNotificationDetails(
      'incoming_messages',
      'Incoming Messages',
      channelDescription: 'Notifications for new incoming chat messages',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const NotificationDetails details = NotificationDetails(android: android);
    await _fln.show(DateTime.now().millisecondsSinceEpoch ~/ 1000, title, body, details);
  }
}



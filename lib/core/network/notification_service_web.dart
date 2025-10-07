// Web implementation using the browser Notification API
// Requires user permission; will no-op if denied

import 'dart:html' as html;

class NotificationService {
  Future<void> initialize() async {
    try {
      if (html.Notification.supported) {
        final permission = await html.Notification.requestPermission();
        // permission: 'granted' | 'denied' | 'default'
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> showIncomingMessage({required String title, required String body}) async {
    try {
      if (!html.Notification.supported) return;
      if (html.Notification.permission != 'granted') return;
      html.Notification(title, body: body);
    } catch (_) {
      // ignore
    }
  }
}



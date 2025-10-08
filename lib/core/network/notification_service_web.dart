// Web implementation using the browser Notification API
// Requires user permission; will no-op if denied
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

class NotificationService {
  Future<void> initialize() async {
    try {
      if (html.Notification.supported) {
        await html.Notification.requestPermission();
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



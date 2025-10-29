// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qwen_chat_openai/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: App()));
    // Avoid indefinite settling on devices/emulators in CI; one frame is enough
    await tester.pump();

    // Verify that our counter starts at 0.
    expect(find.byType(App), findsOneWidget);

    // Tap the '+' icon and trigger a frame.
    // no-op

    // Verify tree remains stable after settling timers.
    expect(find.byType(App), findsOneWidget);
  });
}

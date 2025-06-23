// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Pet Match Game smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PetMatchGame());

    // Verify that our game title is displayed.
    expect(find.text('宠物消消乐'), findsOneWidget);
    expect(find.text('分数'), findsOneWidget);
    expect(find.text('步数'), findsOneWidget);
    expect(find.text('等级'), findsOneWidget);

    // Verify that we have a reset button
    expect(find.text('🔄 重新开始'), findsOneWidget);
  });
}

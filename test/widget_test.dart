import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neumowall/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: NeumoWallApp(),
      ),
    );

    // Verify that the app builds without errors
    expect(find.byType(NeumoWallApp), findsOneWidget);
  });
}

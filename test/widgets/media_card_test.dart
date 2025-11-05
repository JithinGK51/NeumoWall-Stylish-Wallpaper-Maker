import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neumowall/models/media_item.dart';
import 'package:neumowall/widgets/media_card.dart';

void main() {
  group('MediaCard', () {
    testWidgets('displays media card with image', (WidgetTester tester) async {
      final mediaItem = MediaItem(
        id: 'test_1',
        title: 'Test Image',
        type: MediaType.image,
        source: 'https://example.com/image.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaCard(
              mediaItem: mediaItem,
            ),
          ),
        ),
      );

      expect(find.byType(MediaCard), findsOneWidget);
    });

    testWidgets('displays favorite icon when isFavorite is true', (WidgetTester tester) async {
      final mediaItem = MediaItem(
        id: 'test_2',
        title: 'Test Image',
        type: MediaType.image,
        source: 'https://example.com/image.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaCard(
              mediaItem: mediaItem,
              isFavorite: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });
}


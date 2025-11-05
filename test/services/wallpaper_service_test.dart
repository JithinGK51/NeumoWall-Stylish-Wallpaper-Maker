import 'package:flutter_test/flutter_test.dart';
import 'package:neumowall/models/media_item.dart';
import 'package:neumowall/services/wallpaper_service.dart';

void main() {
  group('WallpaperService', () {
    late WallpaperService wallpaperService;

    setUp(() {
      wallpaperService = WallpaperService();
    });

    test('getIOSInstructions returns valid instructions', () {
      final instructions = wallpaperService.getIOSInstructions();
      expect(instructions, isNotEmpty);
      expect(instructions, contains('Photos app'));
      expect(instructions, contains('Use as Wallpaper'));
    });

    test('setWallpaper handles invalid media item gracefully', () async {
      final invalidItem = MediaItem(
        id: 'test',
        title: 'Test',
        type: MediaType.image,
        source: '/invalid/path',
      );

      // Should not throw, but may return false
      final result = await wallpaperService.setWallpaper(
        invalidItem,
        WallpaperType.home,
      );
      
      // Result may be false for invalid paths, which is acceptable
      expect(result, isA<bool>());
    });
  });
}


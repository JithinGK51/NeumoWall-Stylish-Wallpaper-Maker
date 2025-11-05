import 'package:flutter_test/flutter_test.dart';
import 'package:neumowall/services/cache_service.dart';

void main() {
  group('CacheService', () {
    late CacheService cacheService;

    setUp(() {
      cacheService = CacheService();
    });

    test('getCacheDirectory returns valid path', () async {
      final path = await cacheService.getCacheDirectory();
      expect(path, isNotEmpty);
      expect(path, contains('neumowall_cache'));
    });

    test('getCacheSize returns non-negative number', () async {
      final size = await cacheService.getCacheSize();
      expect(size, greaterThanOrEqualTo(0));
    });

    test('clearCache does not throw', () async {
      expect(() => cacheService.clearCache(), returnsNormally);
    });
  });
}


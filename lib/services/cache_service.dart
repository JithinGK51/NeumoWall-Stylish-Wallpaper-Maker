import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/constants.dart';

class CacheService {
  static const int maxCacheSizeBytes = AppConstants.maxCacheSizeMB * 1024 * 1024;

  Future<String> getCacheDirectory() async {
    final directory = await getApplicationCacheDirectory();
    final cacheDir = Directory('${directory.path}/neumowall_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir.path;
  }

  Future<int> getCacheSize() async {
    try {
      final cacheDir = await getCacheDirectory();
      final directory = Directory(cacheDir);
      if (!await directory.exists()) return 0;

      int totalSize = 0;
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  Future<void> clearCache() async {
    try {
      // Clear CachedNetworkImage cache
      await CachedNetworkImage.evictFromCache('');

      // Clear local cache directory
      final cacheDir = await getCacheDirectory();
      final directory = Directory(cacheDir);
      if (await directory.exists()) {
        await for (final entity in directory.list(recursive: true)) {
          if (entity is File) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> evictOldCache() async {
    try {
      final currentSize = await getCacheSize();
      if (currentSize > maxCacheSizeBytes) {
        // Simple eviction: delete files older than 7 days
        final cacheDir = await getCacheDirectory();
        final directory = Directory(cacheDir);
        if (!await directory.exists()) return;

        final now = DateTime.now();
        await for (final entity in directory.list(recursive: true)) {
          if (entity is File) {
            final stat = await entity.stat();
            final age = now.difference(stat.modified);
            if (age.inDays > 7) {
              await entity.delete();
            }
          }
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<String> saveToCache(String url, List<int> bytes) async {
    try {
      final cacheDir = await getCacheDirectory();
      final fileName = url.split('/').last.split('?').first;
      final file = File('$cacheDir/$fileName');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      return '';
    }
  }
}


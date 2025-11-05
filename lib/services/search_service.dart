import '../models/media_item.dart';
import 'media_service.dart';

class SearchService {
  final MediaService _mediaService;

  SearchService(this._mediaService);

  Future<List<MediaItem>> searchMedia(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final queryLower = query.toLowerCase().trim();
    final List<MediaItem> results = [];

    try {
      // Search in featured media
      final featuredMedia = await _mediaService.getFeaturedMedia();
      for (final item in featuredMedia) {
        if (_matchesQuery(item, queryLower)) {
          results.add(item);
        }
      }

      // Search in all categories
      final categories = await _mediaService.getCategories();
      for (final category in categories) {
        final categoryMedia = await _mediaService.getMediaByCategory(category.id);
        for (final item in categoryMedia) {
          if (_matchesQuery(item, queryLower) && !results.any((r) => r.id == item.id)) {
            results.add(item);
          }
        }
      }

      // Search in user media
      try {
        final userMedia = await _mediaService.getUserMedia();
        for (final item in userMedia) {
          if (_matchesQuery(item, queryLower) && !results.any((r) => r.id == item.id)) {
            results.add(item);
          }
        }
      } catch (e) {
        // User media might not be available
      }
    } catch (e) {
      // Return empty on error
    }

    return results;
  }

  bool _matchesQuery(MediaItem item, String queryLower) {
    // Search in title
    if (item.title.toLowerCase().contains(queryLower)) {
      return true;
    }

    // Search in description
    if (item.description != null && item.description!.toLowerCase().contains(queryLower)) {
      return true;
    }

    // Search in category
    if (item.category != null && item.category!.toLowerCase().contains(queryLower)) {
      return true;
    }

    // Search by type (image, video, gif)
    if (queryLower == 'image' && item.type == MediaType.image) {
      return true;
    }
    if (queryLower == 'video' && item.type == MediaType.video) {
      return true;
    }
    if (queryLower == 'gif' && item.type == MediaType.gif) {
      return true;
    }

    return false;
  }

  Future<List<MediaItem>> searchByType(MediaType? type) async {
    final List<MediaItem> results = [];

    if (type == null) {
      return results;
    }

    try {
      // Search in featured media
      final featuredMedia = await _mediaService.getFeaturedMedia();
      for (final item in featuredMedia) {
        if (item.type == type) {
          results.add(item);
        }
      }

      // Search in all categories
      final categories = await _mediaService.getCategories();
      for (final category in categories) {
        final categoryMedia = await _mediaService.getMediaByCategory(category.id);
        for (final item in categoryMedia) {
          if (item.type == type && !results.any((r) => r.id == item.id)) {
            results.add(item);
          }
        }
      }

      // Search in user media
      try {
        final userMedia = await _mediaService.getUserMedia();
        for (final item in userMedia) {
          if (item.type == type && !results.any((r) => r.id == item.id)) {
            results.add(item);
          }
        }
      } catch (e) {
        // User media might not be available
      }
    } catch (e) {
      // Return empty on error
    }

    return results;
  }
}


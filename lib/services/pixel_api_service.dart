import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/media_item.dart';

class PixelApiService {
  static const String _apiKey = 'CoMGI4WUlnfRTx6EwhXkNt0KJqiQ7XIzxuyF5WAriAZuJr2k01WtzrEV';
  static const String _baseUrl = 'https://api.pexels.com/v1';
  static const int _perPage = 20; // Number of photos per page

  /// Search for photos by query
  Future<List<MediaItem>> searchPhotos(
    String query, {
    int page = 1,
    int perPage = _perPage,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/search?query=$query&per_page=$perPage&page=$page',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final photos = data['photos'] as List<dynamic>? ?? [];

        return photos.map((photo) {
          final photoData = photo as Map<String, dynamic>;
          final src = photoData['src'] as Map<String, dynamic>;
          
          // Use large image for wallpaper (high quality)
          final imageUrl = src['large'] as String? ?? 
                          src['medium'] as String? ?? 
                          src['original'] as String? ?? 
                          src['small'] as String ?? '';

          return MediaItem(
            id: 'pixel_${photoData['id']}',
            title: photoData['photographer'] as String? ?? 'Wallpaper',
            description: photoData['alt'] as String?,
            type: MediaType.image,
            source: imageUrl,
            thumbnail: src['small'] as String?,
            category: query.toLowerCase(),
            isBuiltIn: false,
          );
        }).toList();
      } else {
        // Handle API errors
        return [];
      }
    } catch (e) {
      // Handle network errors
      return [];
    }
  }

  /// Get curated/featured photos
  Future<List<MediaItem>> getCuratedPhotos({
    int page = 1,
    int perPage = 40, // Increased default to 40
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/curated?per_page=$perPage&page=$page',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final photos = data['photos'] as List<dynamic>? ?? [];

        return photos.map((photo) {
          final photoData = photo as Map<String, dynamic>;
          final src = photoData['src'] as Map<String, dynamic>;
          
          // Use large image for wallpaper
          final imageUrl = src['large'] as String? ?? 
                          src['medium'] as String? ?? 
                          src['original'] as String? ?? 
                          src['small'] as String ?? '';

          return MediaItem(
            id: 'pixel_${photoData['id']}',
            title: photoData['photographer'] as String? ?? 'Wallpaper',
            description: photoData['alt'] as String?,
            type: MediaType.image,
            source: imageUrl,
            thumbnail: src['small'] as String?,
            isBuiltIn: false,
          );
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Get popular wallpapers by category
  Future<List<MediaItem>> getPopularWallpapers(String category) async {
    // Popular wallpaper searches
    final categoryQueries = {
      'nature': 'nature landscape',
      'animals': 'wildlife animals',
      'cars': 'luxury cars',
      'bikes': 'motorcycle bike',
      'sea': 'ocean sea',
      'ocean': 'ocean waves',
      'fish': 'underwater fish',
      'flowers': 'flowers',
      'anime': 'anime',
      'ninja': 'ninja warrior',
      'buildings': 'modern architecture',
      'swords': 'sword',
      'guns': 'weapon',
      'fighter_jets': 'fighter jet',
      'god': 'divine spiritual',
      'games': 'gaming video games',
      'knights': 'knight medieval armor',
      'game': 'gaming video games', // Alternative for 'game'
    };

    // Use mapped query or fallback to category name with 'wallpaper' suffix
    final categoryLower = category.toLowerCase();
    final mappedQuery = categoryQueries[categoryLower];
    
    // If we have a mapped query, use it; otherwise use category name with 'wallpaper'
    final query = mappedQuery != null 
        ? mappedQuery 
        : '$categoryLower wallpaper';
    
    // Fetch more wallpapers for categories (30 per category)
    return searchPhotos(query, perPage: 30);
  }
}


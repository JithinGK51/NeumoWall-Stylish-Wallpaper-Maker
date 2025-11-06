import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/media_item.dart';
import '../utils/constants.dart';
import 'permission_service.dart';
import 'package:photo_manager/photo_manager.dart';
import 'pixel_api_service.dart';

class MediaService {
  final PermissionService _permissionService = PermissionService();
  final PixelApiService _pixelApiService = PixelApiService();
  List<MediaItem>? _cachedBuiltInMedia;
  List<Category>? _cachedCategories;
  List<MediaItem>? _cachedPixelMedia;

  Future<List<MediaItem>> getFeaturedMedia() async {
    // Combine built-in and Pixel API wallpapers
    final List<MediaItem> allMedia = [];

    // Get built-in media
    try {
      if (_cachedBuiltInMedia == null) {
        try {
          final manifestData =
              await rootBundle.loadString(AppConstants.curatedContentManifest);
          final json = jsonDecode(manifestData) as Map<String, dynamic>;
          final List<dynamic> items = json['featured'] ?? [];
          
          _cachedBuiltInMedia = items
              .map((item) => MediaItem.fromJson(item as Map<String, dynamic>))
              .toList();
        } catch (e) {
          _cachedBuiltInMedia = [];
        }
      }
      allMedia.addAll(_cachedBuiltInMedia ?? []);
    } catch (e) {
      // Continue with Pixel API if built-in fails
    }

    // Get curated photos from Pixel API (always fetch fresh for featured)
    // Fetch 40-50 wallpapers by getting multiple pages
    try {
      final page1 = await _pixelApiService.getCuratedPhotos(perPage: 40, page: 1);
      final page2 = await _pixelApiService.getCuratedPhotos(perPage: 10, page: 2);
      _cachedPixelMedia = [...page1, ...page2];
      allMedia.addAll(_cachedPixelMedia ?? []);
    } catch (e) {
      // If second page fails, use first page only
      try {
        _cachedPixelMedia = await _pixelApiService.getCuratedPhotos(perPage: 40, page: 1);
        allMedia.addAll(_cachedPixelMedia ?? []);
      } catch (e) {
        // Continue with built-in if Pixel API fails
      }
    }

    return allMedia;
  }

  Future<List<Category>> getCategories() async {
    if (_cachedCategories != null) {
      return _cachedCategories!;
    }

    try {
      final manifestData =
          await rootBundle.loadString(AppConstants.curatedContentManifest);
      final json = jsonDecode(manifestData) as Map<String, dynamic>;
      final List<dynamic> categories = json['categories'] ?? [];
      
      _cachedCategories = categories
          .map((cat) => Category.fromJson(cat as Map<String, dynamic>))
          .toList();
      
      return _cachedCategories ?? _getDefaultCategories();
    } catch (e) {
      return _getDefaultCategories();
    }
  }

  Future<List<MediaItem>> getMediaByCategory(String categoryId) async {
    final List<MediaItem> allMedia = [];

    // First try to load from category-specific file
    try {
      final categoryFileName = 'assets/data/$categoryId.json';
      try {
        final categoryData = await rootBundle.loadString(categoryFileName);
        final List<dynamic> items = jsonDecode(categoryData) as List<dynamic>;
        final builtInItems = items
            .map((item) => MediaItem.fromJson(item as Map<String, dynamic>))
            .toList();
        allMedia.addAll(builtInItems);
      } catch (e) {
        // If category file doesn't exist, fall back to main manifest
        try {
          final manifestData =
              await rootBundle.loadString(AppConstants.curatedContentManifest);
          final json = jsonDecode(manifestData) as Map<String, dynamic>;
          final Map<String, dynamic> categoriesData = json['mediaByCategory'] ?? {};
          final List<dynamic> items = categoriesData[categoryId] ?? [];
          
          final builtInItems = items
              .map((item) => MediaItem.fromJson(item as Map<String, dynamic>))
              .toList();
          allMedia.addAll(builtInItems);
        } catch (e) {
          // Continue to Pixel API
        }
      }
    } catch (e) {
      // Continue to Pixel API
    }

    // Always get wallpapers from Pixel API for this category
    // This ensures we have content even if built-in media is empty
    try {
      final pixelMedia = await _pixelApiService.getPopularWallpapers(categoryId);
      if (pixelMedia.isNotEmpty) {
        allMedia.addAll(pixelMedia);
      }
    } catch (e) {
      // If first attempt fails, try again with a simpler query
      try {
        final fallbackQuery = categoryId.toLowerCase().replaceAll('_', ' ');
        final pixelMedia = await _pixelApiService.searchPhotos('$fallbackQuery wallpaper', perPage: 30);
        if (pixelMedia.isNotEmpty) {
          allMedia.addAll(pixelMedia);
        }
      } catch (e2) {
        // Continue with built-in only if both fail
      }
    }
    
    // If still no media after all attempts, try one more time with category name
    if (allMedia.isEmpty) {
      try {
        final categoryName = categoryId.toLowerCase().replaceAll('_', ' ');
        final pixelMedia = await _pixelApiService.searchPhotos(categoryName, perPage: 30);
        allMedia.addAll(pixelMedia);
      } catch (e) {
        // Return empty if everything fails
      }
    }

    return allMedia;
  }

  /// Search media including Pixel API
  Future<List<MediaItem>> searchMedia(String query) async {
    final List<MediaItem> results = [];

    // Search in built-in media
    try {
      if (_cachedBuiltInMedia == null) {
        await getFeaturedMedia(); // This will populate cache
      }
      
      final queryLower = query.toLowerCase();
      for (final item in _cachedBuiltInMedia ?? []) {
        if (item.title.toLowerCase().contains(queryLower) ||
            (item.description?.toLowerCase().contains(queryLower) ?? false) ||
            (item.category?.toLowerCase().contains(queryLower) ?? false)) {
          results.add(item);
        }
      }
    } catch (e) {
      // Continue
    }

    // Search Pixel API
    try {
      final pixelResults = await _pixelApiService.searchPhotos(query, perPage: 20);
      results.addAll(pixelResults);
    } catch (e) {
      // Continue with built-in results
    }

    return results;
  }

  Future<List<MediaItem>> getUserMedia() async {
    if (!await _permissionService.hasStoragePermission()) {
      return [];
    }

    try {
      final List<AssetEntity> assets = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        hasAll: true,
      ).then((paths) async {
        if (paths.isEmpty) return [];
        return await paths.first.getAssetListRange(start: 0, end: 1000);
      });

      // Also get videos
      final List<AssetEntity> videoAssets = await PhotoManager.getAssetPathList(
        type: RequestType.video,
        hasAll: true,
      ).then((paths) async {
        if (paths.isEmpty) return [];
        return await paths.first.getAssetListRange(start: 0, end: 500);
      });

      final List<MediaItem> mediaItems = [];

      for (final asset in assets) {
        final file = await asset.file;
        if (file != null) {
          final filePath = file.path;
          final fileName = filePath.toLowerCase();
          
          // Detect GIF files
          MediaType mediaType = MediaType.image;
          if (fileName.endsWith('.gif')) {
            mediaType = MediaType.gif;
          }
          
          mediaItems.add(MediaItem(
            id: asset.id,
            title: asset.title ?? 'Image',
            type: mediaType,
            source: filePath,
            isBuiltIn: false,
            createdAt: asset.createDateTime,
            fileSize: file.lengthSync(),
          ));
        }
      }

      for (final asset in videoAssets) {
        try {
          final file = await asset.file;
          if (file != null && await file.exists()) {
            final fileInfo = file;
            final durationSeconds = asset.duration;
            
            // Include videos if:
            // 1. Duration is null (unknown duration - include it)
            // 2. Duration is <= 30 seconds (valid for wallpaper)
            // Exclude only videos with duration > 30 seconds
            final shouldInclude = durationSeconds == null || 
                                   durationSeconds <= AppConstants.maxVideoDurationSeconds;
            
            if (shouldInclude) {
              mediaItems.add(MediaItem(
                id: asset.id,
                title: asset.title ?? 'Video',
                type: MediaType.video,
                source: fileInfo.path,
                isBuiltIn: false,
                createdAt: asset.createDateTime,
                duration: durationSeconds != null 
                    ? Duration(seconds: durationSeconds) 
                    : null,
                fileSize: fileInfo.lengthSync(),
              ));
            }
          }
        } catch (e) {
          // Skip this video if there's an error accessing it
          // Continue processing other videos
          continue;
        }
      }

      // Sort by creation date (newest first)
      mediaItems.sort((a, b) {
        final dateA = a.createdAt ?? DateTime(1970);
        final dateB = b.createdAt ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });

      return mediaItems;
    } catch (e) {
      return [];
    }
  }
  
  // Get media organized by type (folder-based)
  Future<Map<String, List<MediaItem>>> getUserMediaByFolder() async {
    final allMedia = await getUserMedia();
    
    final Map<String, List<MediaItem>> organizedMedia = {
      'Images': [],
      'Videos': [],
      'GIFs': [],
    };
    
    for (final item in allMedia) {
      if (item.type == MediaType.image) {
        organizedMedia['Images']!.add(item);
      } else if (item.type == MediaType.video) {
        organizedMedia['Videos']!.add(item);
      } else if (item.type == MediaType.gif) {
        organizedMedia['GIFs']!.add(item);
      }
    }
    
    return organizedMedia;
  }

  Future<List<MediaItem>> getFavorites(Set<String> favoriteIds) async {
    if (favoriteIds.isEmpty) {
      return [];
    }
    
    // Combine built-in and user media to search through
    final List<MediaItem> allMedia = [];
    
    // Add built-in featured media
    if (_cachedBuiltInMedia != null) {
      allMedia.addAll(_cachedBuiltInMedia!);
    }
    
    // Add user media (from gallery)
    try {
      final userMedia = await getUserMedia();
      allMedia.addAll(userMedia);
    } catch (e) {
      // If user media fails to load, continue with built-in only
    }
    
    // Filter favorites from all media
    return allMedia.where((item) => favoriteIds.contains(item.id)).toList();
  }

  List<MediaItem> _getDefaultFeaturedMedia() {
    // Return empty list - in production, this would have default demo assets
    return [];
  }

  List<Category> _getDefaultCategories() {
    return [
      Category(id: 'animals', name: 'Animals', itemCount: 0, description: 'Wildlife and nature'),
      Category(id: 'cars', name: 'Cars', itemCount: 0, description: 'Luxury and sports cars'),
      Category(id: 'bikes', name: 'Bikes', itemCount: 0, description: 'Motorcycles and bikes'),
      Category(id: 'nature', name: 'Nature', itemCount: 0, description: 'Beautiful landscapes'),
      Category(id: 'sea', name: 'Sea', itemCount: 0, description: 'Ocean and beach scenes'),
      Category(id: 'ocean', name: 'Ocean', itemCount: 0, description: 'Underwater world'),
      Category(id: 'fish', name: 'Fish', itemCount: 0, description: 'Marine life'),
      Category(id: 'flowers', name: 'Flowers', itemCount: 0, description: 'Beautiful blooms'),
      Category(id: 'anime', name: 'Anime', itemCount: 0, description: 'Anime characters'),
      Category(id: 'games', name: 'Games', itemCount: 0, description: 'Gaming wallpapers'),
      Category(id: 'knights', name: 'Knights', itemCount: 0, description: 'Epic 3D knight wallpapers'),
      Category(id: 'ninja', name: 'Ninja', itemCount: 0, description: 'Warrior themes'),
      Category(id: 'ants', name: 'Ants', itemCount: 0, description: 'Micro world'),
      Category(id: 'buildings', name: 'Buildings', itemCount: 0, description: 'Architecture'),
      Category(id: 'swords', name: 'Swords', itemCount: 0, description: 'Weapon collection'),
      Category(id: 'guns', name: 'Guns', itemCount: 0, description: 'Firearms'),
      Category(id: 'fighter_jets', name: 'Fighter Jets', itemCount: 0, description: 'Aircraft'),
      Category(id: 'god', name: 'God', itemCount: 0, description: 'Divine themes'),
    ];
  }
}


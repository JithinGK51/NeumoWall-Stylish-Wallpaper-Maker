import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/media_item.dart';
import '../utils/constants.dart';
import 'permission_service.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaService {
  final PermissionService _permissionService = PermissionService();
  List<MediaItem>? _cachedBuiltInMedia;
  List<Category>? _cachedCategories;

  Future<List<MediaItem>> getFeaturedMedia() async {
    if (_cachedBuiltInMedia != null) {
      return _cachedBuiltInMedia!;
    }

    try {
      final manifestData =
          await rootBundle.loadString(AppConstants.curatedContentManifest);
      final json = jsonDecode(manifestData) as Map<String, dynamic>;
      final List<dynamic> items = json['featured'] ?? [];
      
      _cachedBuiltInMedia = items
          .map((item) => MediaItem.fromJson(item as Map<String, dynamic>))
          .toList();
      
      return _cachedBuiltInMedia ?? [];
    } catch (e) {
      // Return empty list if manifest doesn't exist or is invalid
      // In production, this would load from a server or have default assets
      return _getDefaultFeaturedMedia();
    }
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
    try {
      final manifestData =
          await rootBundle.loadString(AppConstants.curatedContentManifest);
      final json = jsonDecode(manifestData) as Map<String, dynamic>;
      final Map<String, dynamic> categoriesData = json['mediaByCategory'] ?? {};
      final List<dynamic> items = categoriesData[categoryId] ?? [];
      
      return items
          .map((item) => MediaItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
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
        final file = await asset.file;
        if (file != null) {
          final fileInfo = await file;
          final durationSeconds = asset.duration;
          if (durationSeconds != null && durationSeconds <= AppConstants.maxVideoDurationSeconds) {
            mediaItems.add(MediaItem(
              id: asset.id,
              title: asset.title ?? 'Video',
              type: MediaType.video,
              source: fileInfo.path,
              isBuiltIn: false,
              createdAt: asset.createDateTime,
              duration: Duration(seconds: durationSeconds),
              fileSize: fileInfo.lengthSync(),
            ));
          }
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
      Category(id: 'nature', name: 'Nature', itemCount: 0),
      Category(id: 'abstract', name: 'Abstract', itemCount: 0),
      Category(id: 'minimalist', name: 'Minimalist', itemCount: 0),
      Category(id: 'dark', name: 'Dark', itemCount: 0),
      Category(id: 'light', name: 'Light', itemCount: 0),
      Category(id: 'gradient', name: 'Gradient', itemCount: 0),
    ];
  }
}


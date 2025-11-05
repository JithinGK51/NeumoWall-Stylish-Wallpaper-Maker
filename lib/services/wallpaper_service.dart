import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import '../models/media_item.dart';
import 'permission_service.dart';

class WallpaperService {
  static const MethodChannel _channel = MethodChannel('neumowall/wallpaper');
  final PermissionService _permissionService = PermissionService();

  Future<bool> setWallpaper(
    MediaItem mediaItem,
    WallpaperType wallpaperType,
  ) async {
    try {
      if (Platform.isAndroid) {
        return await _setWallpaperAndroid(mediaItem, wallpaperType);
      } else if (Platform.isIOS) {
        return await _setWallpaperIOS(mediaItem);
      }
      return false;
    } catch (e) {
      // Log error in production
      return false;
    }
  }

  Future<bool> _setWallpaperAndroid(
    MediaItem mediaItem,
    WallpaperType wallpaperType,
  ) async {
    try {
      String filePath = mediaItem.source;

      // If it's a URL or asset, we need to save it first
      if (mediaItem.source.startsWith('http') ||
          mediaItem.source.startsWith('assets/')) {
        filePath = await _prepareWallpaperFile(mediaItem);
      }

      if (filePath.isEmpty) {
        return false;
      }

      // For images, resize to device screen size
      // Note: Videos and GIFs will use live wallpaper (animated) if supported, otherwise static first frame
      if (mediaItem.isImage) {
        filePath = await _resizeImageForWallpaper(filePath);
      }

      // Determine media type for native code
      String mediaType = 'image';
      if (mediaItem.type == MediaType.video) {
        mediaType = 'video';
      } else if (mediaItem.type == MediaType.gif) {
        mediaType = 'gif';
      }

      final Map<String, dynamic> args = {
        'filePath': filePath,
        'wallpaperType': wallpaperType.toString().split('.').last,
        'mediaType': mediaType,
      };

      final bool result = await _channel.invokeMethod('setWallpaper', args);
      return result;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _setWallpaperIOS(MediaItem mediaItem) async {
    try {
      // iOS doesn't allow programmatic wallpaper setting
      // So we save to Photos and show instructions
      String filePath = mediaItem.source;

      if (mediaItem.source.startsWith('http') ||
          mediaItem.source.startsWith('assets/')) {
        filePath = await _prepareWallpaperFile(mediaItem);
      }

      if (filePath.isEmpty || !File(filePath).existsSync()) {
        return false;
      }

      // Request photo library permission
      final hasPermission = await _permissionService.hasStoragePermission();
      if (!hasPermission) {
        final granted = await _permissionService.requestStoragePermission();
        if (!granted) {
          return false;
        }
      }

      // Save to Photos using share_plus (works on iOS)
      // This will open share sheet where user can save to Photos
      final file = File(filePath);
      if (await file.exists()) {
        try {
          // Use share_plus to save - on iOS this allows saving to Photos
          await Share.shareXFiles([XFile(filePath)]);
          // Return true since share was successful
          // User can then save from share sheet
          return true;
        } catch (e) {
          // If share fails, return true anyway to show instructions
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<String> _prepareWallpaperFile(MediaItem mediaItem) async {
    try {
      final directory = await getTemporaryDirectory();
      // Determine correct file extension based on media type
      String extension;
      if (mediaItem.isImage) {
        extension = 'jpg';
      } else if (mediaItem.type == MediaType.gif) {
        extension = 'gif';
      } else {
        extension = 'mp4'; // For videos
      }
      final fileName = '${mediaItem.id}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      // For assets, copy from assets bundle
      if (mediaItem.source.startsWith('assets/')) {
        try {
          final byteData = await rootBundle.load(mediaItem.source);
          await file.writeAsBytes(byteData.buffer.asUint8List());
          return filePath;
        } catch (e) {
          return '';
        }
      }

      // For URLs, download and save
      if (mediaItem.source.startsWith('http')) {
        try {
          final response = await http.get(Uri.parse(mediaItem.source));
          if (response.statusCode == 200) {
            await file.writeAsBytes(response.bodyBytes);
            return filePath;
          }
          return '';
        } catch (e) {
          return '';
        }
      }

      // For local files, return as-is
      if (File(mediaItem.source).existsSync()) {
        return mediaItem.source;
      }

      return '';
    } catch (e) {
      return '';
    }
  }

  Future<String> _resizeImageForWallpaper(String filePath) async {
    try {
      // For now, return original path
      // In production, you could use image package to resize
      // to match device screen dimensions for optimal quality
      final file = File(filePath);
      if (await file.exists()) {
        return filePath;
      }
      return '';
    } catch (e) {
      return filePath; // Return original on error
    }
  }

  String getIOSInstructions() {
    return '''
To set this as your wallpaper on iOS:

1. Open the Photos app
2. Find the saved image/video
3. Tap the share button
4. Scroll down and tap "Use as Wallpaper"
5. Adjust the position and tap "Set"

Note: iOS doesn't allow apps to set wallpapers automatically for security reasons.
    ''';
  }
}


import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

class PermissionService {
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.photos.isGranted ||
          await Permission.videos.isGranted ||
          await Permission.storage.isGranted) {
        return true;
      }

      // Request appropriate permissions based on Android version
      if (await Permission.photos.request().isGranted ||
          await Permission.videos.request().isGranted) {
        return true;
      }
      
      // Fallback for older Android versions
      if (await Permission.storage.request().isGranted) {
        return true;
      }
    } else if (Platform.isIOS) {
      return await Permission.photos.request().isGranted;
    }
    return false;
  }

  Future<bool> requestCameraPermission() async {
    return await Permission.camera.request().isGranted;
  }

  Future<bool> hasStoragePermission() async {
    if (Platform.isAndroid) {
      return await Permission.photos.isGranted ||
          await Permission.videos.isGranted ||
          await Permission.storage.isGranted;
    } else if (Platform.isIOS) {
      return await Permission.photos.isGranted;
    }
    return false;
  }

  Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }
}


# Deployment Guide - NeumoWall

## Pre-Deployment Checklist

- [x] All build errors fixed
- [x] Code analysis passed (0 errors)
- [x] Unit tests written and passing
- [x] Documentation complete
- [x] Version number updated in pubspec.yaml
- [x] App icons and splash screens configured
- [x] Permissions configured for Android and iOS
- [x] Privacy policy and terms of service ready (if required)

## Android Deployment

### 1. Update Version
Edit `pubspec.yaml`:
```yaml
version: 1.0.0+1
# Format: version_name+build_number
```

### 2. Build Release APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### 3. Build App Bundle (Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### 3. Signing Configuration
For production, configure signing in `android/app/build.gradle.kts`:
```kotlin
signingConfigs {
    release {
        keyAlias = "your-key-alias"
        keyPassword = "your-key-password"
        storeFile = file("path/to/keystore.jks")
        storePassword = "your-store-password"
    }
}
```

### 4. Play Store Requirements
- App icon: 512x512 PNG
- Feature graphic: 1024x500 PNG
- Screenshots (minimum 2)
- Privacy policy URL
- App description
- Category selection

## iOS Deployment

### 1. Update Version
Edit `pubspec.yaml` and `ios/Runner.xcodeproj/project.pbxproj`

### 2. Configure Info.plist
Ensure all required permissions are in `ios/Runner/Info.plist`:
- NSPhotoLibraryUsageDescription
- NSCameraUsageDescription
- NSPhotoLibraryAddUsageDescription

### 3. Build for iOS
```bash
flutter build ios --release
```

### 4. Archive in Xcode
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select "Any iOS Device" as target
3. Product → Archive
4. Distribute App → App Store Connect

### 5. App Store Requirements
- App icon: 1024x1024 PNG
- Screenshots (various sizes)
- App description
- Privacy policy URL
- Age rating
- Category selection

## Testing Before Release

### Android Testing
- [ ] Test on Android 8.0+ (API 26+)
- [ ] Test on Android 13+ (API 33+)
- [ ] Test wallpaper setting functionality
- [ ] Test permissions flow
- [ ] Test image/video import
- [ ] Test favorites system
- [ ] Test theme switching

### iOS Testing
- [ ] Test on iOS 12.0+
- [ ] Test on iOS 17.0+
- [ ] Test save to Photos functionality
- [ ] Test permissions flow
- [ ] Test image/video import
- [ ] Test favorites system
- [ ] Test theme switching

## Release Notes Template

```
Version 1.0.0 - Initial Release

Features:
- Browse beautiful wallpapers from curated collection
- Set wallpapers on home screen, lock screen, or both
- Import your own photos and videos
- Save favorites for quick access
- Crop and adjust images before setting
- Beautiful neumorphic design
- Light and dark themes

Improvements:
- Smooth animations and transitions
- Optimized performance
- Better error handling

Bug Fixes:
- Fixed wallpaper setting on Android
- Improved iOS save flow
```

## Post-Deployment

1. Monitor crash reports (Firebase Crashlytics, Sentry, etc.)
2. Monitor user feedback
3. Track analytics
4. Plan updates based on feedback

## Troubleshooting

### Android Build Issues
- Ensure NDK version matches: `27.0.12077973`
- Clean build: `flutter clean && flutter pub get`
- Check minSdk version compatibility

### iOS Build Issues
- Ensure CocoaPods are updated: `cd ios && pod update`
- Check Info.plist permissions
- Verify signing certificates

---

**Ready for deployment!** 🚀


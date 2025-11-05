# NeumoWall

Stylish, neumorphic wallpaper app for Android & iOS.

Website: https://neumowall.app

## Features

- **Beautiful Neumorphic Design**: Modern 3D soft shadow UI with smooth animations
- **Multiple Media Sources**: Built-in curated wallpapers, user gallery, camera capture, and URL imports
- **Image & Video Support**: Set images or videos (≤30s) as wallpapers
- **Preview & Edit**: Fullscreen preview with pinch-to-zoom, crop/scale for images, trim controls for videos
- **Platform-Specific Wallpaper Setting**:
  - **Android**: Native wallpaper setting (Home/Lock/Both)
  - **iOS**: Save to Photos + user-friendly instructions for manual setting
- **Favorites**: Save your favorite wallpapers
- **Categories**: Browse wallpapers by category (Nature, Abstract, Minimalist, etc.)
- **Onboarding**: Interactive tutorial with animated arrows and tooltips
- **Light/Dark Themes**: Auto theme switching support
- **Responsive Layouts**: Overflow-safe, accessibility-friendly design

## Getting Started

### Prerequisites

- Flutter SDK (3.7.2 or higher)
- Android Studio / Xcode (for platform-specific builds)
- Android SDK / iOS development tools

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd neumowall
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run -d <device>
```

### Building for Release

**Android:**
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## Platform-Specific Notes

### Android

- Supports programmatic wallpaper setting via native MethodChannel
- Handles runtime permissions for storage and camera
- Supports setting wallpaper for Home screen, Lock screen, or Both

### iOS

- iOS doesn't allow silent wallpaper setting via public APIs
- App saves images/videos to Photos and shows instructions overlay
- Users manually set wallpapers through iOS Settings
- Graceful UX fallback with clear instructions

## Project Structure

```
lib/
├── models/          # Data models (MediaItem, Category, UserPreferences)
├── screens/         # App screens (Home, Categories, Preview, Settings, etc.)
├── widgets/         # Reusable widgets (NeumorphicButton, MediaCard, etc.)
├── services/        # Business logic (WallpaperService, MediaService, etc.)
├── providers/       # Riverpod state management
├── themes/          # Neumorphic theme configuration
└── utils/           # Constants and helpers
```

## Adding Curated Content

To add built-in wallpapers:

1. Add images/videos to `assets/images/` or `assets/videos/`
2. Update `assets/data/wallpapers.json` with your content:

```json
{
  "featured": [
    {
      "id": "wallpaper_1",
      "title": "My Wallpaper",
      "type": "image",
      "source": "assets/images/wallpaper_1.jpg",
      "category": "nature",
      "isBuiltIn": true
    }
  ],
  "categories": [...],
  "mediaByCategory": {...}
}
```

## Configuration

### Changing App Name

- Update `android/app/src/main/AndroidManifest.xml` (label attribute)
- Update `ios/Runner/Info.plist` (CFBundleDisplayName)

### Changing App Icon

Replace icons in:
- `android/app/src/main/res/mipmap-*/ic_launcher.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## Testing

Run tests:
```bash
flutter test
```

## Performance Tips

- Use `const` widgets where possible
- Use `RepaintBoundary` for heavy layers (video previews)
- Implement lazy loading for media grids
- Profile memory while trimming/playing videos
- Unload video controllers on dispose

## Accessibility

- All interactive elements have semantic labels
- Large tap targets (min 48x48)
- Screen reader support
- High contrast ratios
- Responsive text scaling

## License

[Add your license here]

## Support

For issues and questions, visit: https://neumowall.app

---

Built with Flutter ❤️

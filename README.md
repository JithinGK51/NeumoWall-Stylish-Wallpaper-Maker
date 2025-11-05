# NeumoWall

Stylish, neumorphic wallpaper app for Android & iOS with animated wallpapers, search, and Google AdMob integration.

Website: https://neumowall.app

## Features

### Core Features
- **Beautiful Neumorphic Design**: Modern 3D soft shadow UI with smooth animations
- **Animated Wallpapers**: Support for videos (≤30s) and GIFs as live wallpapers on Android
- **Search Engine**: Real-time search across all media (images, videos, GIFs) by title, description, category, or type
- **Google AdMob Integration**: Banner ads on all screens with dynamic ad placement
- **Multiple Media Sources**: Built-in curated wallpapers, user gallery, camera capture
- **90+ HD Wallpapers**: Organized into 15 categories with separate JSON files

### Wallpaper Categories
- **Animals**: Lions, Tigers, Eagles, Wolves, Elephants, Bears
- **Cars**: Sports Cars, Supercars, Racing Cars, Classic Cars
- **Bikes**: Sports Bikes, Racing Bikes, Cruisers, Adventure Bikes
- **Nature**: Mountains, Forests, Sunsets, Valleys
- **Sea & Ocean**: Ocean Waves, Underwater Scenes, Beach Sunsets
- **Fish**: Tropical Fish, Sharks, Goldfish, Angelfish
- **Flowers**: Roses, Sunflowers, Tulips, Cherry Blossoms
- **Anime**: Anime Characters, Warriors, Scenes, Cities
- **Ninja**: Ninja Warriors, Shadows, Masters, Assassins
- **Ants**: Ant Colonies, Workers, Warriors, Queens
- **Buildings**: Skyscrapers, Modern Architecture, Futuristic Buildings
- **Swords**: Samurai Swords, Medieval Swords, Excalibur
- **Guns**: Assault Rifles, Sniper Rifles, Handguns
- **Fighter Jets**: Stealth Fighters, Combat Jets, Supersonic Jets

### Media Features
- **Image & Video Support**: Set images or videos (≤30s) as wallpapers
- **GIF Support**: Animated GIF wallpapers with loop playback
- **Animated Wallpapers**: Videos and GIFs play as live wallpapers on Android
- **Preview & Edit**: Fullscreen preview with pinch-to-zoom, crop/scale for images
- **My Media Screen**: Organized gallery with Images, Videos, and GIFs tabs
- **Refresh Functionality**: Pull-to-refresh and refresh button on all screens

### Platform-Specific Features

**Android:**
- Native wallpaper setting (Home/Lock/Both)
- Live wallpaper support for videos and GIFs
- Programmatic wallpaper setting via native MethodChannel
- Handles runtime permissions for storage and camera

**iOS:**
- Save to Photos + user-friendly instructions for manual setting
- iOS doesn't allow silent wallpaper setting via public APIs
- Graceful UX fallback with clear instructions

### User Experience
- **Search**: Real-time search across featured, categories, and user media
- **Favorites**: Save your favorite wallpapers with persistent storage
- **Categories**: Browse 15+ categories with organized folder structure
- **Onboarding**: Interactive 5-step tutorial with animated arrows
- **Light/Dark Themes**: Auto theme switching support
- **Responsive Layouts**: Overflow-safe, accessibility-friendly design
- **Ad Banners**: Google AdMob banner ads on all screens

## Getting Started

### Prerequisites

- Flutter SDK (3.7.2 or higher)
- Android Studio / Xcode (for platform-specific builds)
- Android SDK / iOS development tools
- Google AdMob account (for production ads)

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

3. Configure Google AdMob (Optional):
   - Get your AdMob App ID from https://apps.admob.com
   - Update `android/app/src/main/AndroidManifest.xml` with your App ID:
     ```xml
     <meta-data
         android:name="com.google.android.gms.ads.APPLICATION_ID"
         android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"/>
     ```
   - Update `lib/services/ad_service.dart` with your production ad unit IDs

4. Run the app:
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

## Project Structure

```
lib/
├── models/          # Data models (MediaItem, Category, UserPreferences)
├── screens/         # App screens (Home, Categories, Preview, Settings, etc.)
├── widgets/         # Reusable widgets (NeumorphicButton, MediaCard, AdBanner, etc.)
├── services/        # Business logic (WallpaperService, MediaService, SearchService, AdService)
├── providers/       # Riverpod state management
├── themes/          # Neumorphic theme configuration
└── utils/           # Constants and helpers

assets/
├── images/          # Static wallpaper images
├── videos/          # Video wallpapers and GIFs
├── icons/           # App icons and UI elements
└── data/            # JSON manifest files
    ├── wallpapers.json      # Main manifest with featured and categories
    ├── animals.json         # Animals category wallpapers
    ├── cars.json            # Cars category wallpapers
    ├── bikes.json           # Bikes category wallpapers
    ├── nature.json          # Nature category wallpapers
    ├── sea.json             # Sea category wallpapers
    ├── ocean.json           # Ocean category wallpapers
    ├── fish.json            # Fish category wallpapers
    ├── flowers.json         # Flowers category wallpapers
    ├── anime.json           # Anime category wallpapers
    ├── ninja.json           # Ninja category wallpapers
    ├── ants.json            # Ants category wallpapers
    ├── buildings.json       # Buildings category wallpapers
    ├── swords.json          # Swords category wallpapers
    ├── guns.json            # Guns category wallpapers
    └── fighter_jets.json    # Fighter Jets category wallpapers
```

## Key Features Implementation

### Search Functionality
- Real-time search as you type
- Searches across titles, descriptions, categories, and media types
- Includes built-in and user media
- Accessible from Home Screen AppBar

### Google AdMob Integration
- Banner ads on all screens (Home, Categories, Favorites, My Media, Settings)
- Dynamic ad placement based on screen context
- Test ads configured for development
- Production-ready structure for live ads

### Animated Wallpapers
- Android Live Wallpaper Service for videos and GIFs
- Automatic loop playback
- Fallback to static first frame if live wallpaper not supported
- SharedPreferences for media path and type storage

### Category Organization
- Separate JSON files for each category (15 categories)
- Lazy loading from category-specific files
- Fallback to main manifest if category file missing
- Easy to add new categories and wallpapers

## Adding Wallpapers

### Adding to Categories

Each category has its own JSON file in `assets/data/`. To add wallpapers:

1. Add image files to `assets/images/` or use URLs
2. Update the corresponding category JSON file (e.g., `animals.json`):

```json
[
  {
    "id": "animal_7",
    "title": "3D Panther",
    "description": "Powerful 3D panther",
    "type": "image",
    "source": "https://images.unsplash.com/photo-XXXXX?w=1920&h=1080&fit=crop",
    "category": "animals",
    "isBuiltIn": true
  }
]
```

3. Update the category count in `wallpapers.json`:
```json
{
  "id": "animals",
  "name": "Animals",
  "itemCount": 7,
  "description": "Amazing 3D animal wallpapers"
}
```

### Adding Featured Wallpapers

Update `assets/data/wallpapers.json` in the `featured` array.

## Configuration

### Google AdMob Setup

1. **Get AdMob App ID:**
   - Go to https://apps.admob.com
   - Create an app or select existing
   - Copy the App ID (format: `ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX`)

2. **Update AndroidManifest.xml:**
   ```xml
   <meta-data
       android:name="com.google.android.gms.ads.APPLICATION_ID"
       android:value="YOUR_APP_ID_HERE"/>
   ```

3. **Create Ad Units:**
   - Create banner ad units in AdMob dashboard
   - Update `lib/services/ad_service.dart` with your ad unit IDs:
     ```dart
     static const String _productionBannerAdUnitId = 'YOUR_BANNER_AD_UNIT_ID';
     ```

### Changing App Name

- Update `android/app/src/main/AndroidManifest.xml` (label attribute)
- Update `ios/Runner/Info.plist` (CFBundleDisplayName)

### Changing App Icon

Replace icons in:
- `android/app/src/main/res/mipmap-*/ic_launcher.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## Dependencies

### Key Packages
- `flutter_riverpod: ^2.5.1` - State management
- `google_mobile_ads: ^5.0.0` - Google AdMob integration
- `photo_manager: ^3.0.0` - Gallery access
- `image_picker: ^1.0.7` - Camera and gallery picker
- `video_player: ^2.8.2` - Video playback
- `cached_network_image: ^3.3.1` - Network image caching
- `image_cropper: ^8.0.2` - Image cropping
- `permission_handler: ^11.3.1` - Runtime permissions
- `path_provider: ^2.1.2` - File system paths
- `shared_preferences: ^2.2.3` - Local storage
- `share_plus: ^10.0.2` - Sharing functionality

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
- Cache ad banners to reduce load times

## Accessibility

- All interactive elements have semantic labels
- Large tap targets (min 48x48)
- Screen reader support
- High contrast ratios
- Responsive text scaling

## Version History

### w1.4 (Current)
- ✅ Added Google AdMob integration
- ✅ Added search functionality
- ✅ Created separate category JSON files
- ✅ Added 90+ HD wallpapers across 15 categories
- ✅ Added refresh functionality
- ✅ Improved My Media screen organization

### w1.2
- ✅ Fixed animated wallpaper support (videos/GIFs)
- ✅ Added My Media screen with folder organization
- ✅ Fixed favorites functionality

### w1.1
- ✅ Enhanced media service
- ✅ Improved user media handling

### w1.0
- ✅ Initial release with core features

## License

[Add your license here]

## Support

For issues and questions, visit: https://neumowall.app

---

Built with Flutter ❤️

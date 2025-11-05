# Changelog

All notable changes to NeumoWall will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-XX

### Added
- Initial release of NeumoWall
- Neumorphic design system with custom widgets
- Splash screen with animations
- 5-step interactive onboarding tutorial
- Home screen with featured wallpapers
- Categories browsing with grid layout
- Category detail screen
- My Media screen with gallery import and camera capture
- Favorites system with persistent storage
- Settings screen with theme switching
- Fullscreen preview with zoom, pan, and crop
- Image cropping functionality
- Video playback with controls (≤30s)
- Android native wallpaper setting (Home/Lock/Both)
- iOS save to Photos with instructions
- Share functionality
- Light/Dark theme support
- Auto theme based on system
- Responsive layouts with overflow-safe design
- Unit tests for core services
- Widget tests for critical components
- Comprehensive documentation
- Error handling throughout
- Accessibility support

### Technical
- Flutter 3.7.2+ support
- Riverpod for state management
- Custom neumorphic widgets (replacing flutter_neumorphic)
- Material 3 compatible themes
- Platform-specific implementations
- Android NDK 27.0.12077973
- Kotlin native channel for Android wallpaper setting

### Fixed
- Android NDK version mismatch
- flutter_neumorphic compatibility issues
- Theme configuration for Material 3
- Asset loading from assets/images/
- Wallpaper file preparation for assets/URLs
- Favorites filtering
- Image cropping UI
- iOS permissions configuration

[1.0.0]: https://github.com/JithinGK51/NeumoWall-Stylish-Wallpaper-Maker/releases/tag/v1.0.0


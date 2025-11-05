class AppConstants {
  // App info
  static const String appName = 'NeumoWall';
  static const String appWebsite = 'https://neumowall.app';
  static const String appVersion = '1.0.0';

  // Media limits
  static const int maxVideoDurationSeconds = 30;
  static const int maxCacheSizeMB = 500; // 500MB default cache limit

  // UI constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double minTapTargetSize = 48.0;

  // Grid layout
  static const int gridCrossAxisCount = 2;
  static const double gridChildAspectRatio = 0.75;
  static const double gridSpacing = 12.0;

  // Preview
  static const double minZoomScale = 1.0;
  static const double maxZoomScale = 3.0;
  static const double initialZoomScale = 1.0;

  // Storage keys
  static const String prefsKey = 'neumowall_preferences';
  static const String favoritesKey = 'favorites';
  static const String onboardingKey = 'has_completed_onboarding';

  // Asset paths
  static const String curatedContentManifest = 'assets/data/wallpapers.json';
}


enum AppThemeMode { light, dark, auto }

enum AppAnimationQuality { high, medium, low }

class UserPreferences {
  final AppThemeMode themeMode;
  final AppAnimationQuality animationQuality;
  final bool hasCompletedOnboarding;
  final Set<String> favoriteIds;
  final int? cacheSizeMB;

  UserPreferences({
    this.themeMode = AppThemeMode.auto,
    this.animationQuality = AppAnimationQuality.high,
    this.hasCompletedOnboarding = false,
    Set<String>? favoriteIds,
    this.cacheSizeMB,
  }) : favoriteIds = favoriteIds ?? {};

  UserPreferences copyWith({
    AppThemeMode? themeMode,
    AppAnimationQuality? animationQuality,
    bool? hasCompletedOnboarding,
    Set<String>? favoriteIds,
    int? cacheSizeMB,
  }) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      animationQuality: animationQuality ?? this.animationQuality,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      cacheSizeMB: cacheSizeMB ?? this.cacheSizeMB,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.toString().split('.').last,
      'animationQuality': animationQuality.toString().split('.').last,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'favoriteIds': favoriteIds.toList(),
      'cacheSizeMB': cacheSizeMB,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      themeMode: AppThemeMode.values.firstWhere(
        (e) => e.toString().split('.').last == json['themeMode'],
        orElse: () => AppThemeMode.auto,
      ),
      animationQuality: AppAnimationQuality.values.firstWhere(
        (e) => e.toString().split('.').last == json['animationQuality'],
        orElse: () => AppAnimationQuality.high,
      ),
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
      favoriteIds: (json['favoriteIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          {},
      cacheSizeMB: json['cacheSizeMB'] as int?,
    );
  }
}


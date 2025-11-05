import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_preferences.dart';
import '../utils/constants.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

final preferencesProvider =
    StateNotifierProvider<PreferencesNotifier, UserPreferences>((ref) {
  return PreferencesNotifier(ref);
});

class PreferencesNotifier extends StateNotifier<UserPreferences> {
  final Ref _ref;

  PreferencesNotifier(this._ref) : super(UserPreferences()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefsAsync = await _ref.read(sharedPreferencesProvider.future);
      final prefs = prefsAsync;
      final hasCompletedOnboarding =
          prefs.getBool(AppConstants.onboardingKey) ?? false;
      final favoriteIds = prefs.getStringList(AppConstants.favoritesKey) ?? [];
      
      // Load theme mode
      final themeModeString = prefs.getString('themeMode') ?? 'auto';
      final themeMode = AppThemeMode.values.firstWhere(
        (e) => e.toString().split('.').last == themeModeString,
        orElse: () => AppThemeMode.auto,
      );
      
      // Load animation quality
      final animationQualityString = prefs.getString('animationQuality') ?? 'high';
      final animationQuality = AppAnimationQuality.values.firstWhere(
        (e) => e.toString().split('.').last == animationQualityString,
        orElse: () => AppAnimationQuality.high,
      );
      
      state = UserPreferences(
        themeMode: themeMode,
        animationQuality: animationQuality,
        hasCompletedOnboarding: hasCompletedOnboarding,
        favoriteIds: favoriteIds.toSet(),
      );
    } catch (e) {
      // Keep default preferences on error
    }
  }

  Future<void> updateThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _savePreferences();
  }

  Future<void> updateAnimationQuality(AppAnimationQuality quality) async {
    state = state.copyWith(animationQuality: quality);
    await _savePreferences();
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    state = state.copyWith(hasCompletedOnboarding: completed);
    final prefsAsync = await _ref.read(sharedPreferencesProvider.future);
    final prefs = prefsAsync;
    await prefs.setBool(AppConstants.onboardingKey, completed);
  }

  Future<void> toggleFavorite(String mediaId) async {
    final newFavorites = Set<String>.from(state.favoriteIds);
    if (newFavorites.contains(mediaId)) {
      newFavorites.remove(mediaId);
    } else {
      newFavorites.add(mediaId);
    }
    state = state.copyWith(favoriteIds: newFavorites);
    
    final prefsAsync = await _ref.read(sharedPreferencesProvider.future);
    final prefs = prefsAsync;
    await prefs.setStringList(
        AppConstants.favoritesKey, newFavorites.toList());
  }

  Future<void> clearCache() async {
    // Cache clearing logic will be in CacheService
    state = state.copyWith(cacheSizeMB: 0);
  }

  Future<void> _savePreferences() async {
    try {
      final prefsAsync = await _ref.read(sharedPreferencesProvider.future);
      final prefs = prefsAsync;
      await prefs.setString('themeMode', state.themeMode.toString().split('.').last);
      await prefs.setString('animationQuality', state.animationQuality.toString().split('.').last);
    } catch (e) {
      // Handle error silently
    }
  }
}


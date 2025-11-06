import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/theme_service.dart';

final themeColorsProvider = FutureProvider<Map<String, Color>?>((ref) async {
  return await ThemeService.loadThemeColors();
});

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, AsyncValue<Map<String, Color>?>>((ref) {
  return ThemeNotifier(ref);
});

class ThemeNotifier extends StateNotifier<AsyncValue<Map<String, Color>?>> {
  final Ref _ref;

  ThemeNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final colors = await ThemeService.loadThemeColors();
      state = AsyncValue.data(colors);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateTheme(Color primaryColor, Color secondaryColor) async {
    await ThemeService.saveThemeColors(primaryColor, secondaryColor);
    state = AsyncValue.data({
      'primary': primaryColor,
      'secondary': secondaryColor,
    });
    // Invalidate the future provider to trigger rebuild
    _ref.invalidate(themeColorsProvider);
  }

  Future<void> resetTheme() async {
    await ThemeService.clearTheme();
    state = const AsyncValue.data(null);
    _ref.invalidate(themeColorsProvider);
  }
}


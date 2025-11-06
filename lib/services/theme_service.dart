import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ThemeService {
  static const String _themePrimaryColorKey = 'theme_primary_color';
  static const String _themeSecondaryColorKey = 'theme_secondary_color';
  static const String _themeAppliedKey = 'theme_applied';

  /// Extract theme colors from wallpaper category
  static Map<String, Color> extractThemeFromCategory(String? category) {
    final categoryLower = (category ?? '').toLowerCase();
    
    switch (categoryLower) {
      case 'nature':
      case 'sea':
      case 'ocean':
        return {
          'primary': const Color(0xFF11998E),
          'secondary': const Color(0xFF38EF7D),
        };
      case 'animals':
        return {
          'primary': const Color(0xFFFF6B6B),
          'secondary': const Color(0xFFFF8E53),
        };
      case 'cars':
        return {
          'primary': const Color(0xFF4ECDC4),
          'secondary': const Color(0xFF44A08D),
        };
      case 'bikes':
        return {
          'primary': const Color(0xFF667EEA),
          'secondary': const Color(0xFF764BA2),
        };
      case 'fish':
        return {
          'primary': const Color(0xFF0072FF),
          'secondary': const Color(0xFF00C6FF),
        };
      case 'flowers':
        return {
          'primary': const Color(0xFFFF6B9D),
          'secondary': const Color(0xFFC44569),
        };
      case 'anime':
        return {
          'primary': const Color(0xFFA855F7),
          'secondary': const Color(0xFFE879F9),
        };
      case 'ninja':
      case 'dark':
        return {
          'primary': const Color(0xFF1F1C2C),
          'secondary': const Color(0xFF928DAB),
        };
      case 'ants':
        return {
          'primary': const Color(0xFFFFA726),
          'secondary': const Color(0xFFFF6F00),
        };
      case 'buildings':
        return {
          'primary': const Color(0xFF37474F),
          'secondary': const Color(0xFF546E7A),
        };
      case 'swords':
        return {
          'primary': const Color(0xFFB71C1C),
          'secondary': const Color(0xFF880E4F),
        };
      case 'guns':
        return {
          'primary': const Color(0xFF424242),
          'secondary': const Color(0xFF212121),
        };
      case 'fighter_jets':
        return {
          'primary': const Color(0xFF0F4C75),
          'secondary': const Color(0xFF3282B8),
        };
      case 'god':
        return {
          'primary': const Color(0xFFFFD700),
          'secondary': const Color(0xFFFFA500),
        };
      default:
        return {
          'primary': const Color(0xFF6C5CE7),
          'secondary': const Color(0xFF6C5CE7),
        };
    }
  }

  /// Save theme colors to preferences
  static Future<void> saveThemeColors(Color primaryColor, Color secondaryColor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themePrimaryColorKey, primaryColor.value);
    await prefs.setInt(_themeSecondaryColorKey, secondaryColor.value);
    await prefs.setBool(_themeAppliedKey, true);
  }

  /// Load saved theme colors
  static Future<Map<String, Color>?> loadThemeColors() async {
    final prefs = await SharedPreferences.getInstance();
    final primaryValue = prefs.getInt(_themePrimaryColorKey);
    final secondaryValue = prefs.getInt(_themeSecondaryColorKey);
    final isApplied = prefs.getBool(_themeAppliedKey) ?? false;

    if (primaryValue != null && secondaryValue != null && isApplied) {
      return {
        'primary': Color(primaryValue),
        'secondary': Color(secondaryValue),
      };
    }
    return null;
  }

  /// Clear saved theme (reset to default)
  static Future<void> clearTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themePrimaryColorKey);
    await prefs.remove(_themeSecondaryColorKey);
    await prefs.setBool(_themeAppliedKey, false);
  }

  /// Check if custom theme is applied
  static Future<bool> isCustomThemeApplied() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeAppliedKey) ?? false;
  }
}


import 'package:flutter/material.dart';
// Removed flutter_neumorphic import - using custom implementation

class NeumorphicThemeConfig {
  // Animation constants
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Curve animationCurve = Curves.easeInOut;
  static const Duration fastAnimationDuration = Duration(milliseconds: 200);
  static const Duration slowAnimationDuration = Duration(milliseconds: 400);

  // Neumorphic depth
  static const double depth = 8.0;
  static const double lightDepth = 4.0;
  static const double deepDepth = 12.0;

  // Border radius (2xl - 1.5rem = 24px)
  static const double borderRadius = 24.0;
  static const double smallBorderRadius = 12.0;
  static const double largeBorderRadius = 32.0;
  
  // Padding constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double minTapTargetSize = 48.0;

  // Color palettes
  static const Color lightBackground = Color(0xFFE6E9EF);
  static const Color lightSurface = Color(0xFFF5F7FA);
  static const Color lightAccent = Color(0xFF6C5CE7);
  static const Color lightText = Color(0xFF2D3436);
  static const Color lightTextSecondary = Color(0xFF636E72);

  static const Color darkBackground = Color(0xFF1E1E2E);
  static const Color darkSurface = Color(0xFF2D2D3D);
  static const Color darkAccent = Color(0xFF8B7FFF);
  static const Color darkText = Color(0xFFEDF2F7);
  static const Color darkTextSecondary = Color(0xFFA0AEC0);

  // Light theme with optional custom colors
  static ThemeData lightTheme({Color? primaryColor, Color? secondaryColor}) {
    final primary = primaryColor ?? lightAccent;
    final secondary = secondaryColor ?? lightAccent;
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: lightSurface,
        error: const Color(0xFFE74C3C),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightText,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: lightBackground,
      canvasColor: lightSurface,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: lightText,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: lightText,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: lightText,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightText,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: lightText,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: lightText,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: lightTextSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: lightTextSecondary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: lightText),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightText,
        ),
      ),
    );
  }

  // Dark theme with optional custom colors
  static ThemeData darkTheme({Color? primaryColor, Color? secondaryColor}) {
    final primary = primaryColor ?? darkAccent;
    final secondary = secondaryColor ?? darkAccent;
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: darkSurface,
        error: const Color(0xFFE74C3C),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkText,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: darkBackground,
      canvasColor: darkSurface,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkText,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: darkText,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: darkText,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: darkTextSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: darkTextSecondary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: darkText),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
      ),
    );
  }

  // Neumorphic style helpers (using custom implementation)
  // These are now handled by CustomNeumorphic widget
  static Color getLightShadowColor(Brightness brightness) {
    return brightness == Brightness.dark
        ? const Color(0xFF3D3D4D)
        : Colors.white;
  }

  static Color getDarkShadowColor(Brightness brightness) {
    return brightness == Brightness.dark
        ? const Color(0xFF0F0F1F)
        : const Color(0xFFB8BCC8);
  }

  // Helper to get theme based on brightness
  static ThemeData getTheme(Brightness brightness, {Color? primaryColor, Color? secondaryColor}) {
    return brightness == Brightness.dark 
        ? darkTheme(primaryColor: primaryColor, secondaryColor: secondaryColor)
        : lightTheme(primaryColor: primaryColor, secondaryColor: secondaryColor);
  }

  // Getter methods for backward compatibility
  static ThemeData get lightThemeDefault => lightTheme();
  static ThemeData get darkThemeDefault => darkTheme();
}


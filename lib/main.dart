import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'themes/neumorphic_theme.dart';
import 'providers/preferences_provider.dart';
import 'models/user_preferences.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';
import 'services/ad_service.dart';
import 'services/theme_service.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Google Mobile Ads
  await AdService.initialize();
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: NeumoWallApp(),
    ),
  );
}

class NeumoWallApp extends ConsumerWidget {
  const NeumoWallApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesProvider);
    final customThemeAsync = ref.watch(themeNotifierProvider);
    
    // Determine theme mode
    ThemeMode themeMode;
    switch (preferences.themeMode) {
      case AppThemeMode.light:
        themeMode = ThemeMode.light;
        break;
      case AppThemeMode.dark:
        themeMode = ThemeMode.dark;
        break;
      case AppThemeMode.auto:
      default:
        themeMode = ThemeMode.system;
    }

    // Get custom theme colors if available
    final customTheme = customThemeAsync.valueOrNull;
    final primaryColor = customTheme?['primary'];
    final secondaryColor = customTheme?['secondary'];

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: NeumorphicThemeConfig.lightTheme(
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
      ),
      darkTheme: NeumorphicThemeConfig.darkTheme(
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
      ),
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}

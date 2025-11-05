import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'themes/neumorphic_theme.dart';
import 'providers/preferences_provider.dart';
import 'models/user_preferences.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
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

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: NeumorphicThemeConfig.lightTheme,
      darkTheme: NeumorphicThemeConfig.darkTheme,
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}

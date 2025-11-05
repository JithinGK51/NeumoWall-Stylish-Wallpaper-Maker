import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../providers/preferences_provider.dart';
import '../models/user_preferences.dart';
import '../themes/neumorphic_theme.dart';
import '../utils/constants.dart';
import '../services/cache_service.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesProvider);
    final cacheService = CacheService();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(NeumorphicThemeConfig.defaultPadding),
          children: [
            _buildSectionHeader(context, 'Appearance'),
            _buildThemeModeTile(context, ref, preferences),
            _buildAnimationQualityTile(context, ref, preferences),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Storage'),
            _buildCacheTile(context, ref, cacheService),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'About'),
            _buildOnboardingTile(context, ref),
            _buildAboutTile(context),
            _buildVersionTile(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildThemeModeTile(
    BuildContext context,
    WidgetRef ref,
    UserPreferences preferences,
  ) {
    return ListTile(
      leading: const Icon(Icons.palette),
      title: const Text('Theme'),
      subtitle: Text(preferences.themeMode.toString().split('.').last.toUpperCase()),
      trailing: DropdownButton<AppThemeMode>(
        value: preferences.themeMode,
        items: AppThemeMode.values.map((mode) {
          return DropdownMenuItem(
            value: mode,
            child: Text(mode.toString().split('.').last.toUpperCase()),
          );
        }).toList(),
        onChanged: (mode) {
          if (mode != null) {
            ref.read(preferencesProvider.notifier).updateThemeMode(mode);
          }
        },
      ),
    );
  }

  Widget _buildAnimationQualityTile(
    BuildContext context,
    WidgetRef ref,
    UserPreferences preferences,
  ) {
    return ListTile(
      leading: const Icon(Icons.animation),
      title: const Text('Animation Quality'),
      subtitle: Text(preferences.animationQuality.toString().split('.').last.toUpperCase()),
      trailing: DropdownButton<AppAnimationQuality>(
        value: preferences.animationQuality,
        items: AppAnimationQuality.values.map((quality) {
          return DropdownMenuItem(
            value: quality,
            child: Text(quality.toString().split('.').last.toUpperCase()),
          );
        }).toList(),
        onChanged: (quality) {
          if (quality != null) {
            ref.read(preferencesProvider.notifier).updateAnimationQuality(quality);
          }
        },
      ),
    );
  }

  Widget _buildCacheTile(
    BuildContext context,
    WidgetRef ref,
    CacheService cacheService,
  ) {
    return ListTile(
      leading: const Icon(Icons.storage),
      title: const Text('Clear Cache'),
      subtitle: const Text('Free up storage space'),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () async {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.warning,
            title: 'Clear Cache',
            desc: 'Are you sure you want to clear all cached images?',
            btnOkOnPress: () async {
              await cacheService.clearCache();
              ref.read(preferencesProvider.notifier).clearCache();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache cleared')),
                );
              }
            },
            btnCancelOnPress: () {},
          ).show();
        },
      ),
    );
  }

  Widget _buildOnboardingTile(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.school),
      title: const Text('Show Onboarding'),
      subtitle: const Text('View the tutorial again'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      },
    );
  }

  Widget _buildAboutTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info),
      title: const Text('About'),
      subtitle: Text(AppConstants.appWebsite),
      trailing: const Icon(Icons.open_in_new, size: 16),
      onTap: () {
        // Open website in browser
      },
    );
  }

  Widget _buildVersionTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.code),
      title: const Text('Version'),
      subtitle: Text('v${AppConstants.appVersion}'),
    );
  }
}


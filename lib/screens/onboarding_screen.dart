import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/preferences_provider.dart';
import '../themes/neumorphic_theme.dart';
import '../widgets/neumorphic_button.dart';
import '../widgets/custom_neumorphic.dart';
import '../utils/constants.dart';
import 'main_navigation.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingStep> _steps = [
    const OnboardingStep(
      title: 'Browse Wallpapers',
      description: 'Swipe through categories and discover beautiful wallpapers',
      icon: Icons.explore,
    ),
    const OnboardingStep(
      title: 'Preview & Zoom',
      description: 'Pinch to zoom and pan to see every detail',
      icon: Icons.zoom_in,
    ),
    const OnboardingStep(
      title: 'Crop & Trim',
      description: 'Adjust images or trim videos to fit perfectly',
      icon: Icons.crop,
    ),
    const OnboardingStep(
      title: 'Set Wallpaper',
      description: 'Set as home screen, lock screen, or both',
      icon: Icons.wallpaper,
    ),
    const OnboardingStep(
      title: 'Favorites & Settings',
      description: 'Save favorites and customize your experience',
      icon: Icons.favorite,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: NeumorphicThemeConfig.animationDuration,
        curve: NeumorphicThemeConfig.animationCurve,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    await ref.read(preferencesProvider.notifier).setOnboardingCompleted(true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(NeumorphicThemeConfig.defaultPadding),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  return _buildPage(_steps[index]);
                },
              ),
            ),

            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: NeumorphicThemeConfig.defaultPadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _steps.length,
                  (index) => _buildDot(index),
                ),
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(NeumorphicThemeConfig.defaultPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: NeumorphicThemeConfig.animationDuration,
                          curve: NeumorphicThemeConfig.animationCurve,
                        );
                      },
                      child: const Text('Previous'),
                    )
                  else
                    const SizedBox.shrink(),
                  NeumorphicButton(
                    label: _currentPage == _steps.length - 1
                        ? 'Get Started'
                        : 'Next',
                    icon: _currentPage == _steps.length - 1
                        ? Icons.check
                        : Icons.arrow_forward,
                    onPressed: _nextPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingStep step) {
    return Padding(
      padding: const EdgeInsets.all(NeumorphicThemeConfig.largePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomNeumorphic(
            depth: NeumorphicThemeConfig.deepDepth,
            borderRadius: BorderRadius.circular(60),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Icon(
                step.icon,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            step.title,
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                step.description,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Animated arrow indicator
          Icon(
            Icons.swipe,
            size: 48,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: NeumorphicThemeConfig.fastAnimationDuration,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.primary.withOpacity(0.3),
      ),
    );
  }
}

class OnboardingStep {
  final String title;
  final String description;
  final IconData icon;

  const OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}


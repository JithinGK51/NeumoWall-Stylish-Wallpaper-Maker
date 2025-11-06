import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/ad_banner.dart';
import '../providers/media_provider.dart';
import '../themes/neumorphic_theme.dart';
import '../utils/constants.dart';
import '../widgets/custom_neumorphic.dart';
import 'category_detail_screen.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // App Bar with gradient
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Categories',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Ad Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AdBanner(screenName: 'Categories'),
              ),
            ),
            // Content
            categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 80,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No categories available',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final category = categories[index];
                        return _AnimatedCategoryCard(
                          category: category,
                          index: index,
                          animationController: _animationController,
                        );
                      },
                      childCount: categories.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: LoadingIndicator()),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading categories',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.invalidate(categoriesProvider);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedCategoryCard extends StatelessWidget {
  final dynamic category;
  final int index;
  final AnimationController animationController;

  const _AnimatedCategoryCard({
    required this.category,
    required this.index,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final delay = index * 0.1;
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(
          delay.clamp(0.0, 0.8),
          (delay + 0.3).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value,
            child: _CategoryCard(category: category),
          ),
        );
      },
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final dynamic category;

  const _CategoryCard({required this.category});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _scaleController.value = 1.0;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'animals':
        return Icons.pets;
      case 'cars':
        return Icons.directions_car;
      case 'bikes':
        return Icons.two_wheeler;
      case 'nature':
        return Icons.landscape;
      case 'sea':
      case 'ocean':
        return Icons.water;
      case 'fish':
        return Icons.set_meal;
      case 'flowers':
        return Icons.local_florist;
      case 'anime':
        return Icons.animation;
      case 'games':
        return Icons.games;
      case 'knights':
      case 'knight':
        return Icons.shield;
      case 'ninja':
        return Icons.sports_martial_arts;
      case 'ants':
        return Icons.bug_report;
      case 'buildings':
        return Icons.business;
      case 'swords':
        return Icons.sports_mma;
      case 'guns':
        return Icons.security;
      case 'fighter_jets':
        return Icons.flight;
      case 'god':
        return Icons.auto_awesome;
      default:
        return Icons.category;
    }
  }

  List<Color> _getCategoryGradient(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'animals':
        return [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)];
      case 'cars':
        return [const Color(0xFF4ECDC4), const Color(0xFF44A08D)];
      case 'bikes':
        return [const Color(0xFF667EEA), const Color(0xFF764BA2)];
      case 'nature':
        return [const Color(0xFF11998E), const Color(0xFF38EF7D)];
      case 'sea':
      case 'ocean':
        return [const Color(0xFF00C9FF), const Color(0xFF92FE9D)];
      case 'fish':
        return [const Color(0xFF0072FF), const Color(0xFF00C6FF)];
      case 'flowers':
        return [const Color(0xFFFF6B9D), const Color(0xFFC44569)];
      case 'anime':
        return [const Color(0xFFA855F7), const Color(0xFFE879F9)];
      case 'games':
        return [const Color(0xFF9C27B0), const Color(0xFFE91E63)];
      case 'knights':
      case 'knight':
        return [const Color(0xFF6A1B9A), const Color(0xFF9C27B0)];
      case 'ninja':
        return [const Color(0xFF1F1C2C), const Color(0xFF928DAB)];
      case 'ants':
        return [const Color(0xFFFFA726), const Color(0xFFFF6F00)];
      case 'buildings':
        return [const Color(0xFF37474F), const Color(0xFF546E7A)];
      case 'swords':
        return [const Color(0xFFB71C1C), const Color(0xFF880E4F)];
      case 'guns':
        return [const Color(0xFF424242), const Color(0xFF212121)];
      case 'fighter_jets':
        return [const Color(0xFF0F4C75), const Color(0xFF3282B8)];
      case 'god':
        return [const Color(0xFFFFD700), const Color(0xFFFFA500)];
      default:
        return [
          Theme.of(context).colorScheme.primary,
          Theme.of(context).colorScheme.secondary,
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _getCategoryGradient(widget.category.id);
    final icon = _getCategoryIcon(widget.category.id);

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _scaleController.reverse();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _scaleController.forward();
        // Navigate to category detail screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CategoryDetailScreen(
              categoryId: widget.category.id,
              categoryName: widget.category.name,
            ),
          ),
        );
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _scaleController.forward();
      },
      child: ScaleTransition(
        scale: _scaleController,
        child: CustomNeumorphic(
          depth: _isPressed ? 4.0 : 12.0,
          borderRadius: BorderRadius.circular(24),
          padding: EdgeInsets.zero,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with glow effect
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Category name
                  Text(
                    widget.category.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Description or item count
                  if (widget.category.description != null)
                    Text(
                      widget.category.description as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else if (widget.category.itemCount != null &&
                      widget.category.itemCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.category.itemCount} wallpapers',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

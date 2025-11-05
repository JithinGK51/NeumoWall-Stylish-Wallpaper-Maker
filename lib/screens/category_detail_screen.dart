import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/media_card.dart';
import '../widgets/loading_indicator.dart';
import '../providers/media_provider.dart';
import '../providers/preferences_provider.dart';
import '../utils/constants.dart';
import '../themes/neumorphic_theme.dart';
import 'preview_screen.dart';

class CategoryDetailScreen extends ConsumerWidget {
  final String categoryId;
  final String categoryName;

  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryMediaAsync = ref.watch(categoryMediaProvider(categoryId));

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(categoryName),
        ),
        body: categoryMediaAsync.when(
          data: (mediaItems) {
            if (mediaItems.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No wallpapers in this category',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 600 ? 3 : AppConstants.gridCrossAxisCount;
                final spacing = AppConstants.gridSpacing;
                final padding = NeumorphicThemeConfig.defaultPadding;

                return Padding(
                  padding: EdgeInsets.all(padding),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: AppConstants.gridChildAspectRatio,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                    ),
                    itemCount: mediaItems.length,
                    itemBuilder: (context, index) {
                      final item = mediaItems[index];
                      final isFavorite = ref.watch(preferencesProvider).favoriteIds.contains(item.id);

                      return Hero(
                        tag: 'media_${item.id}',
                        child: MediaCard(
                          mediaItem: item,
                          isFavorite: isFavorite,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PreviewScreen(mediaItem: item),
                              ),
                            );
                          },
                          onFavoriteToggle: () {
                            ref.read(preferencesProvider.notifier).toggleFavorite(item.id);
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: LoadingIndicator()),
          error: (error, stack) => Center(
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
                  'Error loading wallpapers',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


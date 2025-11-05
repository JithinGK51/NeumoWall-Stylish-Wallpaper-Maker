import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/media_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/ad_banner.dart';
import '../providers/media_provider.dart';
import '../providers/preferences_provider.dart';
import '../models/media_item.dart';
import '../utils/constants.dart';
import '../themes/neumorphic_theme.dart';
import 'preview_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final featuredMediaAsync = ref.watch(featuredMediaProvider);
    final searchResultsAsync = _isSearching && _searchQuery.isNotEmpty
        ? ref.watch(searchResultsProvider(_searchQuery))
        : null;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search images, videos, GIFs...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                )
              : const Text('NeumoWall'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    _searchQuery = '';
                  }
                });
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Ad Banner
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AdBanner(screenName: 'NeumoWall Home'),
            ),
            // Content
            Expanded(
              child: _buildContent(context, ref, featuredMediaAsync, searchResultsAsync),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<MediaItem>> featuredMediaAsync,
    AsyncValue<List<MediaItem>>? searchResultsAsync,
  ) {
    // Show search results if searching
    if (_isSearching && _searchQuery.isNotEmpty && searchResultsAsync != null) {
      return searchResultsAsync.when(
        data: (results) {
          if (results.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No results found',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try different keywords',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }

          return _buildMediaGrid(context, ref, results);
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
                'Error searching',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    // Show featured media if not searching
    return featuredMediaAsync.when(
      data: (mediaItems) {
        if (mediaItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wallpaper_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No wallpapers available',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(featuredMediaProvider);
          },
          child: _buildMediaGrid(context, ref, mediaItems),
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
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                ref.invalidate(featuredMediaProvider);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaGrid(BuildContext context, WidgetRef ref, List<MediaItem> mediaItems) {
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
  }
}


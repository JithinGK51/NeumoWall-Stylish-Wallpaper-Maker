import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/media_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/ad_banner.dart';
import '../providers/media_provider.dart';
import '../providers/preferences_provider.dart';
import '../utils/constants.dart';
import '../themes/neumorphic_theme.dart';
import '../services/permission_service.dart';
import '../models/media_item.dart';
import 'preview_screen.dart';

class MyMediaScreen extends ConsumerStatefulWidget {
  const MyMediaScreen({super.key});

  @override
  ConsumerState<MyMediaScreen> createState() => _MyMediaScreenState();
}

class _MyMediaScreenState extends ConsumerState<MyMediaScreen> with SingleTickerProviderStateMixin {
  final ImagePicker _imagePicker = ImagePicker();
  final PermissionService _permissionService = PermissionService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery({MediaType? type}) async {
    final hasPermission = await _permissionService.hasStoragePermission();
    if (!hasPermission) {
      final granted = await _permissionService.requestStoragePermission();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission is required')),
        );
        return;
      }
    }

    try {
      if (type == MediaType.image) {
        // Use pickMultipleMedia for better multi-select support
        final List<XFile>? pickedFiles = await _imagePicker.pickMultipleMedia(
          imageQuality: 90,
        );
        if (pickedFiles != null && pickedFiles.isNotEmpty && mounted) {
          ref.invalidate(myMediaByFolderProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${pickedFiles.length} image(s) imported successfully')),
          );
        }
      } else if (type == MediaType.video) {
        final XFile? pickedFile = await _imagePicker.pickVideo(
          source: ImageSource.gallery,
          maxDuration: const Duration(seconds: 30),
        );
        if (pickedFile != null && mounted) {
          ref.invalidate(myMediaByFolderProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video imported successfully')),
          );
        }
      } else {
        // Allow picking all types (images, videos, GIFs)
        final List<XFile>? pickedFiles = await _imagePicker.pickMultipleMedia();
        if (pickedFiles != null && pickedFiles.isNotEmpty && mounted) {
          ref.invalidate(myMediaByFolderProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${pickedFiles.length} media file(s) imported successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing media: $e')),
        );
      }
    }
  }

  Future<void> _captureFromCamera() async {
    final hasPermission = await _permissionService.hasCameraPermission();
    if (!hasPermission) {
      final granted = await _permissionService.requestCameraPermission();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required')),
        );
        return;
      }
    }

    final pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null && mounted) {
      ref.invalidate(myMediaByFolderProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo captured successfully')),
      );
    }
  }

  void _showImportDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Import Images'),
              subtitle: const Text('Select multiple images from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery(type: MediaType.image);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Import Video'),
              subtitle: const Text('Select video from gallery (≤30s)'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery(type: MediaType.video);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              subtitle: const Text('Using camera'),
              onTap: () {
                Navigator.pop(context);
                _captureFromCamera();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaGrid(List<MediaItem> mediaItems) {
    if (mediaItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No media found',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _showImportDialog,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Import Media'),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => ref.invalidate(myMediaByFolderProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
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
  }

  Future<void> _refreshMedia() async {
    ref.invalidate(myMediaByFolderProvider);
    // Wait for the refresh to complete
    await ref.read(myMediaByFolderProvider.future);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Media refreshed'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaByFolderAsync = ref.watch(myMediaByFolderProvider);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Media'),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.image),
                text: 'Images',
              ),
              Tab(
                icon: Icon(Icons.video_library),
                text: 'Videos',
              ),
              Tab(
                icon: Icon(Icons.animation),
                text: 'GIFs',
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshMedia,
              tooltip: 'Refresh Media',
            ),
            IconButton(
              icon: const Icon(Icons.add_photo_alternate),
              onPressed: _showImportDialog,
              tooltip: 'Import Media',
            ),
          ],
        ),
        body: Column(
          children: [
            // Ad Banner
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AdBanner(screenName: 'My Media'),
            ),
            // Content
            Expanded(
              child: mediaByFolderAsync.when(
                data: (mediaByFolder) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      RefreshIndicator(
                        onRefresh: _refreshMedia,
                        child: _buildMediaGrid(mediaByFolder['Images'] ?? []),
                      ),
                      RefreshIndicator(
                        onRefresh: _refreshMedia,
                        child: _buildMediaGrid(mediaByFolder['Videos'] ?? []),
                      ),
                      RefreshIndicator(
                        onRefresh: _refreshMedia,
                        child: _buildMediaGrid(mediaByFolder['GIFs'] ?? []),
                      ),
                    ],
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
                        'Error loading media',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _refreshMedia,
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

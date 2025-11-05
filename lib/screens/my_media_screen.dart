import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/media_card.dart';
import '../widgets/loading_indicator.dart';
import '../providers/media_provider.dart';
import '../providers/preferences_provider.dart';
import '../utils/constants.dart';
import '../themes/neumorphic_theme.dart';
import '../services/permission_service.dart';
import 'preview_screen.dart';

class MyMediaScreen extends ConsumerStatefulWidget {
  const MyMediaScreen({super.key});

  @override
  ConsumerState<MyMediaScreen> createState() => _MyMediaScreenState();
}

class _MyMediaScreenState extends ConsumerState<MyMediaScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final PermissionService _permissionService = PermissionService();

  Future<void> _pickFromGallery() async {
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

    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      ref.invalidate(myMediaProvider);
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
      ref.invalidate(myMediaProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myMediaAsync = ref.watch(myMediaProvider);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Media'),
          centerTitle: true,
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.photo_library),
                      SizedBox(width: 8),
                      Text('Pick from Gallery'),
                    ],
                  ),
                  onTap: _pickFromGallery,
                ),
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.camera_alt),
                      SizedBox(width: 8),
                      Text('Take Photo'),
                    ],
                  ),
                  onTap: _captureFromCamera,
                ),
              ],
            ),
          ],
        ),
        body: myMediaAsync.when(
          data: (mediaItems) {
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
                    TextButton(
                      onPressed: _pickFromGallery,
                      child: const Text('Import from Gallery'),
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
                  'Error loading media',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    ref.invalidate(myMediaProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


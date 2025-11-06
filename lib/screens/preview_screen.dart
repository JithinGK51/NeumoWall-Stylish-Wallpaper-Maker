import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import '../models/media_item.dart';
import '../services/wallpaper_service.dart';
import '../themes/neumorphic_theme.dart';
import '../utils/constants.dart';
import '../widgets/neumorphic_button.dart';
import '../widgets/device_preview.dart';
import '../providers/preferences_provider.dart';
import '../providers/theme_provider.dart';
import '../services/theme_service.dart';

class PreviewScreen extends ConsumerStatefulWidget {
  final MediaItem mediaItem;

  const PreviewScreen({super.key, required this.mediaItem});

  @override
  ConsumerState<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends ConsumerState<PreviewScreen> {
  late TransformationController _transformationController;
  VideoPlayerController? _videoController;
  bool _isDimmed = false;
  bool _isVideoInitialized = false;
  String? _croppedImagePath;
  bool _showDevicePreview = true; // Default to device preview

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    
    // Only initialize video for actual video files, not GIFs
    if (widget.mediaItem.type == MediaType.video) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      String videoPath = widget.mediaItem.source;
      
      // Handle asset paths - copy to temp file first
      if (videoPath.startsWith('assets/')) {
        final tempDir = await getTemporaryDirectory();
        final fileName = videoPath.split('/').last;
        final tempFile = File('${tempDir.path}/$fileName');
        
        // Copy asset to temp file
        final byteData = await rootBundle.load(videoPath);
        await tempFile.writeAsBytes(byteData.buffer.asUint8List());
        videoPath = tempFile.path;
      }

      _videoController = VideoPlayerController.file(File(videoPath));
      await _videoController!.initialize();
      _videoController!.setLooping(true);
      _videoController!.play();
      
      setState(() {
        _isVideoInitialized = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading video: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _cropImage() async {
    if (!widget.mediaItem.isImage) return;
    
    try {
      String imagePath = widget.mediaItem.source;
      
      // Handle asset paths - need to copy to temp first
      if (imagePath.startsWith('assets/')) {
        // For assets, we'd need to copy to temp file first
        // For now, skip cropping for assets
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Crop not available for built-in wallpapers')),
        );
        return;
      }
      
      // Handle network images - need to download first
      if (imagePath.startsWith('http')) {
        // Would need to download first
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please download the image first')),
        );
        return;
      }
      
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        aspectRatio: const CropAspectRatio(ratioX: 9, ratioY: 16), // Common phone aspect ratio
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Wallpaper',
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Wallpaper',
            aspectRatioLockEnabled: false,
          ),
        ],
      );
      
      if (croppedFile != null) {
        setState(() {
          _croppedImagePath = croppedFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cropping image: $e')),
        );
      }
    }
  }

  Future<void> _setWallpaper(WallpaperType type) async {
    final wallpaperService = WallpaperService();
    
    // Use cropped image if available
    final mediaItem = _croppedImagePath != null
        ? widget.mediaItem.copyWith(source: _croppedImagePath!)
        : widget.mediaItem;
    
    // Extract theme colors from wallpaper and apply
    if (widget.mediaItem.isImage) {
      _applyThemeFromWallpaper();
    }
    
    final success = await wallpaperService.setWallpaper(mediaItem, type);

    if (mounted) {
      if (Platform.isIOS && success) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.info,
          title: 'Wallpaper Saved',
          desc: wallpaperService.getIOSInstructions(),
          btnOkOnPress: () {},
        ).show();
      } else if (success) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          title: 'Success',
          desc: 'Wallpaper set successfully!',
          btnOkOnPress: () {},
        ).show();
      } else {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: 'Error',
          desc: 'Failed to set wallpaper. Please try again.',
          btnOkOnPress: () {},
        ).show();
      }
    }
  }

  void _showSetWallpaperDialog() {
    if (Platform.isIOS) {
      _setWallpaper(WallpaperType.home); // iOS doesn't support different types
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Set Wallpaper',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home Screen'),
              onTap: () {
                Navigator.pop(context);
                _setWallpaper(WallpaperType.home);
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Lock Screen'),
              onTap: () {
                Navigator.pop(context);
                _setWallpaper(WallpaperType.lock);
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text('Both'),
              onTap: () {
                Navigator.pop(context);
                _setWallpaper(WallpaperType.both);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _shareWallpaper() async {
    try {
      if (widget.mediaItem.source.startsWith('http')) {
        await Share.share(widget.mediaItem.source);
      } else {
        final file = File(widget.mediaItem.source);
        if (await file.exists()) {
          await Share.shareXFiles([XFile(widget.mediaItem.source)]);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to share')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDimmed ? Colors.black87 : Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Media preview (device preview by default)
            Center(
              child: _showDevicePreview
                  ? DevicePreview(
                      mediaItem: widget.mediaItem,
                      videoController: _videoController,
                      isVideoInitialized: _isVideoInitialized,
                      croppedImagePath: _croppedImagePath,
                    )
                  : (widget.mediaItem.type == MediaType.video
                      ? _buildVideoPreview()
                      : _buildImagePreview()),
            ),

            // Top app bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  actions: [
                    // Device/Full preview toggle
                    IconButton(
                      icon: Icon(
                        _showDevicePreview ? Icons.fullscreen : Icons.phone_android,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _showDevicePreview = !_showDevicePreview;
                        });
                      },
                      tooltip: _showDevicePreview ? 'Full Preview' : 'Device Preview',
                    ),
                    if (widget.mediaItem.isImage)
                      IconButton(
                        icon: const Icon(Icons.crop, color: Colors.white),
                        onPressed: _cropImage,
                        tooltip: 'Crop Image',
                      ),
                    IconButton(
                      icon: Icon(
                        _isDimmed ? Icons.brightness_high : Icons.brightness_low,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _isDimmed = !_isDimmed;
                        });
                      },
                      tooltip: 'Toggle Background',
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: _shareWallpaper,
                      tooltip: 'Share',
                    ),
                  ],
                ),
              ),
            ),

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(NeumorphicThemeConfig.defaultPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.mediaItem.type == MediaType.video) _buildVideoControls(),
                    const SizedBox(height: 16),
                    NeumorphicButton(
                      label: 'Set Wallpaper',
                      icon: Icons.wallpaper,
                      onPressed: _showSetWallpaperDialog,
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    final isAsset = widget.mediaItem.source.startsWith('assets/');
    final isNetwork = widget.mediaItem.source.startsWith('http');
    
    // Use cropped image if available
    final imageSource = _croppedImagePath ?? widget.mediaItem.source;

    // For GIFs, try to load as asset or file
    if (widget.mediaItem.type == MediaType.gif) {
      return InteractiveViewer(
        transformationController: _transformationController,
        minScale: AppConstants.minZoomScale,
        maxScale: AppConstants.maxZoomScale,
        child: Center(
          child: isAsset
              ? Image.asset(
                  imageSource,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.white),
                )
              : Image.file(
                  File(imageSource),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.white),
                ),
        ),
      );
    }

    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: AppConstants.minZoomScale,
      maxScale: AppConstants.maxZoomScale,
      child: Center(
        child: isNetwork
            ? CachedNetworkImage(
                imageUrl: imageSource,
                fit: BoxFit.contain,
                errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
              )
            : isAsset
                ? Image.asset(
                    imageSource,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.white),
                  )
                : Image.file(
                    File(imageSource),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.white),
                  ),
      ),
    );
  }

  Widget _buildVideoPreview() {
    if (!_isVideoInitialized || _videoController == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: VideoPlayer(_videoController!),
      ),
    );
  }

  Widget _buildVideoControls() {
    if (_videoController == null || !_isVideoInitialized) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              if (_videoController!.value.isPlaying) {
                _videoController!.pause();
              } else {
                _videoController!.play();
              }
            });
          },
        ),
        Expanded(
          child: VideoProgressIndicator(
            _videoController!,
            allowScrubbing: true,
            colors: VideoProgressColors(
              playedColor: Theme.of(context).colorScheme.primary,
              bufferedColor: Colors.white24,
              backgroundColor: Colors.white12,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            _formatDuration(_videoController!.value.position),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Extract and apply theme colors from wallpaper
  Future<void> _applyThemeFromWallpaper() async {
    // Extract theme colors based on category
    final themeColors = ThemeService.extractThemeFromCategory(widget.mediaItem.category);
    final primaryColor = themeColors['primary']!;
    final secondaryColor = themeColors['secondary']!;
    
    // Update theme through provider (will trigger app rebuild)
    ref.read(themeNotifierProvider.notifier).updateTheme(primaryColor, secondaryColor);
    
    // Show confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.palette, color: Colors.white),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Theme updated to match wallpaper!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: primaryColor,
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }
}


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import '../models/media_item.dart';

enum DevicePreviewMode { home, lock }

class DevicePreview extends StatefulWidget {
  final MediaItem mediaItem;
  final VideoPlayerController? videoController;
  final bool isVideoInitialized;
  final BoxFit fit;
  final String? croppedImagePath;

  const DevicePreview({
    super.key,
    required this.mediaItem,
    this.videoController,
    this.isVideoInitialized = false,
    this.fit = BoxFit.cover,
    this.croppedImagePath,
  });

  @override
  State<DevicePreview> createState() => _DevicePreviewState();
}

class _DevicePreviewState extends State<DevicePreview> {
  DevicePreviewMode _previewMode = DevicePreviewMode.home;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxWidth = screenSize.width * 0.85;
    final maxHeight = screenSize.height * 0.75;
    
    final deviceWidth = maxWidth;
    final deviceHeight = deviceWidth * 2.1;
    
    final adjustedHeight = deviceHeight > maxHeight ? maxHeight : deviceHeight;
    final adjustedWidth = adjustedHeight / 2.1;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Preview mode toggle
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildModeButton(context, 'Home', DevicePreviewMode.home, Icons.home),
                  const SizedBox(width: 8),
                  _buildModeButton(context, 'Lock', DevicePreviewMode.lock, Icons.lock),
                ],
              ),
            ),
            // Device preview
            Stack(
              alignment: Alignment.center,
              children: [
                _buildDeviceFrame(context, adjustedWidth, adjustedHeight),
                _buildDeviceScreen(context, adjustedWidth, adjustedHeight),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context,
    String label,
    DevicePreviewMode mode,
    IconData icon,
  ) {
    final isSelected = _previewMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _previewMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceFrame(BuildContext context, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 10,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(32),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: width * 0.4,
            right: width * 0.4,
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: width * 0.35,
            right: width * 0.35,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceScreen(BuildContext context, double width, double height) {
    final screenWidth = width - 16;
    final screenHeight = height - 16;
    
    return Container(
      width: screenWidth,
      height: screenHeight,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(32),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildMediaContent(context),
          _buildDeviceUI(context, screenWidth, screenHeight),
        ],
      ),
    );
  }

  Widget _buildDeviceUI(BuildContext context, double width, double height) {
    if (_previewMode == DevicePreviewMode.lock) {
      return _buildLockScreenUI(context, width, height);
    } else {
      return _buildHomeScreenUI(context, width, height);
    }
  }

  Widget _buildLockScreenUI(BuildContext context, double width, double height) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 24,
          child: _buildStatusBar(context),
        ),
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '10:30',
                style: TextStyle(
                  fontSize: width * 0.15,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  letterSpacing: -2,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Monday, January 15',
                style: TextStyle(
                  fontSize: width * 0.04,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                margin: const EdgeInsets.only(bottom: 40),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHomeScreenUI(BuildContext context, double width, double height) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 28,
          child: _buildStatusBar(context),
        ),
        Positioned(
          top: 28,
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildHomeScreenContent(context, width, height - 28),
        ),
      ],
    );
  }

  Widget _buildStatusBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _previewMode == DevicePreviewMode.lock ? '10:30' : '9:41',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusIcon(Icons.signal_cellular_4_bar, Colors.white),
              const SizedBox(width: 4),
              _buildStatusIcon(Icons.wifi, Colors.white),
              const SizedBox(width: 4),
              _buildStatusIcon(Icons.battery_full, Colors.white),
              const SizedBox(width: 4),
              const Text(
                '78%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(IconData icon, Color color) {
    return Icon(icon, size: 14, color: color);
  }

  Widget _buildHomeScreenContent(BuildContext context, double width, double height) {
    final apps = [
      {'icon': Icons.chrome_reader_mode, 'name': 'Chrome', 'color': const Color(0xFF4285F4)},
      {'icon': Icons.message, 'name': 'Messages', 'color': const Color(0xFF34A853)},
      {'icon': Icons.camera_alt, 'name': 'Camera', 'color': const Color(0xFFEA4335)},
      {'icon': Icons.photo_library, 'name': 'Photos', 'color': const Color(0xFFFBBC04)},
      {'icon': Icons.music_note, 'name': 'Music', 'color': const Color(0xFF9C27B0)},
      {'icon': Icons.settings, 'name': 'Settings', 'color': const Color(0xFF757575)},
      {'icon': Icons.mail, 'name': 'Mail', 'color': const Color(0xFF1A73E8)},
      {'icon': Icons.calendar_today, 'name': 'Calendar', 'color': const Color(0xFFEA4335)},
      {'icon': Icons.map, 'name': 'Maps', 'color': const Color(0xFF4285F4)},
      {'icon': Icons.shopping_cart, 'name': 'Shop', 'color': const Color(0xFFFBBC04)},
      {'icon': Icons.games, 'name': 'Games', 'color': const Color(0xFF9C27B0)},
      {'icon': Icons.video_library, 'name': 'Videos', 'color': const Color(0xFFE91E63)},
      {'icon': Icons.cloud, 'name': 'Drive', 'color': const Color(0xFF4285F4)},
      {'icon': Icons.chat_bubble, 'name': 'Chat', 'color': const Color(0xFF34A853)},
      {'icon': Icons.work, 'name': 'Work', 'color': const Color(0xFF1976D2)},
      {'icon': Icons.restaurant, 'name': 'Food', 'color': const Color(0xFFFF6F00)},
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.1),
          ],
        ),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildAppGrid(context, width, apps),
            const SizedBox(height: 16),
            Container(
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomNavIcon(Icons.home, true),
                  _buildBottomNavIcon(Icons.search, false),
                  _buildBottomNavIcon(Icons.add_box_outlined, false),
                  _buildBottomNavIcon(Icons.favorite_border, false),
                  _buildBottomNavIcon(Icons.person_outline, false),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAppGrid(BuildContext context, double width, List<Map<String, dynamic>> apps) {
    final crossAxisCount = 4;
    final spacing = width * 0.02;
    final itemSize = (width - spacing * (crossAxisCount + 1)) / crossAxisCount;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(spacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1,
      ),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        return _buildAppIcon(
          context,
          app['icon'] as IconData,
          app['name'] as String,
          app['color'] as Color,
          itemSize,
        );
      },
    );
  }

  Widget _buildAppIcon(
    BuildContext context,
    IconData icon,
    String name,
    Color color,
    double size,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: size * 0.5,
            height: size * 0.5,
            decoration: BoxDecoration(
              color: color.withOpacity(0.8),
              borderRadius: BorderRadius.circular(size * 0.12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: size * 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.12,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 4,
                ),
              ],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavIcon(IconData icon, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildMediaContent(BuildContext context) {
    switch (widget.mediaItem.type) {
      case MediaType.video:
        return _buildVideoContent(context);
      case MediaType.gif:
        return _buildGifContent(context);
      case MediaType.image:
      default:
        return _buildImageContent(context);
    }
  }

  Widget _buildImageContent(BuildContext context) {
    final isAsset = widget.mediaItem.source.startsWith('assets/');
    final isNetwork = widget.mediaItem.source.startsWith('http');
    final imageSource = widget.croppedImagePath ?? widget.mediaItem.source;

    Widget imageWidget;
    
    if (isNetwork) {
      imageWidget = CachedNetworkImage(
        imageUrl: imageSource,
        fit: widget.fit,
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[900],
          child: const Center(
            child: Icon(Icons.error, color: Colors.white54),
          ),
        ),
      );
    } else if (isAsset) {
      imageWidget = Image.asset(
        imageSource,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[900],
          child: const Center(
            child: Icon(Icons.error, color: Colors.white54),
          ),
        ),
      );
    } else {
      imageWidget = Image.file(
        File(imageSource),
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[900],
          child: const Center(
            child: Icon(Icons.error, color: Colors.white54),
          ),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: imageWidget,
    );
  }

  Widget _buildVideoContent(BuildContext context) {
    if (!widget.isVideoInitialized || widget.videoController == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white54),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: AspectRatio(
        aspectRatio: widget.videoController!.value.aspectRatio,
        child: VideoPlayer(widget.videoController!),
      ),
    );
  }

  Widget _buildGifContent(BuildContext context) {
    final isAsset = widget.mediaItem.source.startsWith('assets/');
    final isNetwork = widget.mediaItem.source.startsWith('http');
    final imageSource = widget.croppedImagePath ?? widget.mediaItem.source;

    Widget gifWidget;
    
    if (isNetwork) {
      gifWidget = CachedNetworkImage(
        imageUrl: imageSource,
        fit: widget.fit,
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[900],
          child: const Center(
            child: Icon(Icons.error, color: Colors.white54),
          ),
        ),
      );
    } else if (isAsset) {
      gifWidget = Image.asset(
        imageSource,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[900],
          child: const Center(
            child: Icon(Icons.error, color: Colors.white54),
          ),
        ),
      );
    } else {
      gifWidget = Image.file(
        File(imageSource),
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[900],
          child: const Center(
            child: Icon(Icons.error, color: Colors.white54),
          ),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: gifWidget,
    );
  }
}


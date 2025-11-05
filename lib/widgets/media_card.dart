import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/media_item.dart';
import '../themes/neumorphic_theme.dart';
import '../utils/constants.dart';
import 'neumorphic_card.dart';

class MediaCard extends StatelessWidget {
  final MediaItem mediaItem;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const MediaCard({
    super.key,
    required this.mediaItem,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(NeumorphicThemeConfig.borderRadius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildMediaThumbnail(context),
          if (mediaItem.isVideo) _buildVideoIndicator(context),
          if (mediaItem.type == MediaType.gif) _buildGifIndicator(context),
          if (onFavoriteToggle != null) _buildFavoriteButton(context),
        ],
      ),
    );
  }

  Widget _buildMediaThumbnail(BuildContext context) {
    final isAsset = mediaItem.source.startsWith('assets/');
    final isNetwork = mediaItem.source.startsWith('http');

    Widget imageWidget;

    if (isNetwork) {
      imageWidget = CachedNetworkImage(
        imageUrl: mediaItem.source,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    } else if (isAsset) {
      // For asset videos, show a placeholder (videos can't be displayed as static images)
      // For GIFs, try to load as asset (Flutter supports animated GIFs)
      if (mediaItem.type == MediaType.video) {
        imageWidget = _buildAssetVideoGifPlaceholder(context);
      } else if (mediaItem.type == MediaType.gif) {
        // Try to load GIF as asset, fallback to placeholder if it fails
        imageWidget = Image.asset(
          mediaItem.source,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildAssetVideoGifPlaceholder(context),
        );
      } else {
        // For asset images, use Image.asset
        imageWidget = Image.asset(
          mediaItem.source,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildAssetVideoGifPlaceholder(context),
        );
      }
    } else {
      // Local file - use Image.file for proper display
      final file = File(mediaItem.source);
      if (file.existsSync()) {
        imageWidget = Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return frame == null
                ? Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : child;
          },
        );
      } else {
        imageWidget = Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(NeumorphicThemeConfig.borderRadius),
      child: imageWidget,
    );
  }

  Widget _buildAssetVideoGifPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.6),
            Theme.of(context).colorScheme.secondary.withOpacity(0.6),
            Theme.of(context).colorScheme.tertiary.withOpacity(0.6),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          mediaItem.type == MediaType.gif ? Icons.animation : Icons.play_circle_outline,
          size: 48,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildVideoIndicator(BuildContext context) {
    return Positioned(
      bottom: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.play_circle_outline,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            if (mediaItem.duration != null)
              Text(
                _formatDuration(mediaItem.duration!),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGifIndicator(BuildContext context) {
    return Positioned(
      bottom: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.animation,
              color: Colors.white,
              size: 16,
            ),
            SizedBox(width: 4),
            Text(
              'GIF',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: GestureDetector(
        onTap: onFavoriteToggle,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black26,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}


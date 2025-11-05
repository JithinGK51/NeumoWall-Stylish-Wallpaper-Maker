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
      imageWidget = Image.asset(
        mediaItem.source,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
      );
    } else {
      imageWidget = Image.asset(
        'assets/images/placeholder.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(NeumorphicThemeConfig.borderRadius),
      child: imageWidget,
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


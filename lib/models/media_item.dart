enum MediaType { image, video, gif }

enum WallpaperType { home, lock, both }

class MediaItem {
  final String id;
  final String title;
  final String? description;
  final MediaType type;
  final String source; // local path, asset path, or URL
  final String? thumbnail;
  final String? category;
  final bool isBuiltIn;
  final DateTime? createdAt;
  final Duration? duration; // For videos/GIFs
  final int? fileSize;

  MediaItem({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.source,
    this.thumbnail,
    this.category,
    this.isBuiltIn = false,
    this.createdAt,
    this.duration,
    this.fileSize,
  });

  bool get isVideo => type == MediaType.video || type == MediaType.gif;
  bool get isImage => type == MediaType.image;

  MediaItem copyWith({
    String? id,
    String? title,
    String? description,
    MediaType? type,
    String? source,
    String? thumbnail,
    String? category,
    bool? isBuiltIn,
    DateTime? createdAt,
    Duration? duration,
    int? fileSize,
  }) {
    return MediaItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      source: source ?? this.source,
      thumbnail: thumbnail ?? this.thumbnail,
      category: category ?? this.category,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      createdAt: createdAt ?? this.createdAt,
      duration: duration ?? this.duration,
      fileSize: fileSize ?? this.fileSize,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'source': source,
      'thumbnail': thumbnail,
      'category': category,
      'isBuiltIn': isBuiltIn,
      'createdAt': createdAt?.toIso8601String(),
      'duration': duration?.inSeconds,
      'fileSize': fileSize,
    };
  }

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: MediaType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => MediaType.image,
      ),
      source: json['source'] as String,
      thumbnail: json['thumbnail'] as String?,
      category: json['category'] as String?,
      isBuiltIn: json['isBuiltIn'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      duration: json['duration'] != null
          ? Duration(seconds: json['duration'] as int)
          : null,
      fileSize: json['fileSize'] as int?,
    );
  }
}

class Category {
  final String id;
  final String name;
  final String? icon;
  final String? description;
  final int itemCount;

  Category({
    required this.id,
    required this.name,
    this.icon,
    this.description,
    this.itemCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
      'itemCount': itemCount,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      description: json['description'] as String?,
      itemCount: json['itemCount'] as int? ?? 0,
    );
  }
}


import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/media_item.dart';
import '../services/media_service.dart';
import 'preferences_provider.dart';

final mediaServiceProvider = Provider<MediaService>((ref) {
  return MediaService();
});

final featuredMediaProvider = FutureProvider<List<MediaItem>>((ref) async {
  final service = ref.read(mediaServiceProvider);
  return service.getFeaturedMedia();
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final service = ref.read(mediaServiceProvider);
  return service.getCategories();
});

final categoryMediaProvider =
    FutureProvider.family<List<MediaItem>, String>((ref, categoryId) async {
  final service = ref.read(mediaServiceProvider);
  return service.getMediaByCategory(categoryId);
});

final favoritesProvider = FutureProvider<List<MediaItem>>((ref) async {
  final prefs = ref.watch(preferencesProvider);
  final service = ref.read(mediaServiceProvider);
  
  // Ensure featured media is loaded first
  await ref.read(featuredMediaProvider.future);
  
  return service.getFavorites(prefs.favoriteIds);
});

final myMediaProvider = FutureProvider<List<MediaItem>>((ref) async {
  final service = ref.read(mediaServiceProvider);
  return service.getUserMedia();
});

final myMediaByFolderProvider = FutureProvider<Map<String, List<MediaItem>>>((ref) async {
  final service = ref.read(mediaServiceProvider);
  return service.getUserMediaByFolder();
});


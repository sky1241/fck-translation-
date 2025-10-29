import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/photo_gallery_item.dart';
import '../data/photo_repository.dart';
import '../data/photo_cache_service.dart';
import '../domain/i_photo_repository.dart';

final photoRepositoryProvider = Provider<IPhotoRepository>((ref) {
  return PhotoRepository();
});

final photoCacheServiceProvider = Provider<PhotoCacheService>((ref) {
  return PhotoCacheService();
});

final photoGalleryControllerProvider =
    NotifierProvider<PhotoGalleryController, PhotoGalleryState>(
  PhotoGalleryController.new,
);

class PhotoGalleryState {
  final List<PhotoGalleryItem> photos;
  final bool isLoading;
  final String? error;
  final int totalCount;
  final String cacheSize;

  const PhotoGalleryState({
    this.photos = const [],
    this.isLoading = false,
    this.error,
    this.totalCount = 0,
    this.cacheSize = '0 B',
  });

  PhotoGalleryState copyWith({
    List<PhotoGalleryItem>? photos,
    bool? isLoading,
    String? error,
    int? totalCount,
    String? cacheSize,
  }) {
    return PhotoGalleryState(
      photos: photos ?? this.photos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalCount: totalCount ?? this.totalCount,
      cacheSize: cacheSize ?? this.cacheSize,
    );
  }
}

class PhotoGalleryController extends Notifier<PhotoGalleryState> {
  late final IPhotoRepository _photoRepository;
  late final PhotoCacheService _cacheService;

  @override
  PhotoGalleryState build() {
    _photoRepository = ref.watch(photoRepositoryProvider);
    _cacheService = ref.watch(photoCacheServiceProvider);
    return const PhotoGalleryState();
  }

  /// Charger toutes les photos
  Future<void> loadPhotos() async {
    print('[PhotoGalleryController] 🔵 loadPhotos called');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final photos = await _photoRepository.getAllPhotos();
      final count = photos.length;
      print('[PhotoGalleryController] 📸 Loaded ${count} photos from repository');
      
      final cacheBytes = await _cacheService.getCacheSize();
      final cacheSize = _cacheService.formatCacheSize(cacheBytes);

      state = state.copyWith(
        photos: photos,
        totalCount: count,
        cacheSize: cacheSize,
        isLoading: false,
      );
      
      print('[PhotoGalleryController] ✅ State updated with ${count} photos');
    } catch (e) {
      print('[PhotoGalleryController] ❌ Error loading photos: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors du chargement des photos',
      );
    }
  }

  /// Télécharger une photo et la mettre en cache
  Future<void> downloadPhoto(String photoId, String url) async {
    try {
      // Mettre à jour le status à "downloading"
      await _photoRepository.updatePhotoStatus(photoId, PhotoStatus.downloading);
      await loadPhotos(); // Refresh UI

      // Télécharger
      final localPath = await _cacheService.cachePhoto(url, photoId);

      if (localPath != null) {
        await _photoRepository.updatePhotoStatus(
          photoId,
          PhotoStatus.cached,
          localPath: localPath,
        );
      } else {
        await _photoRepository.updatePhotoStatus(photoId, PhotoStatus.error);
      }

      await loadPhotos(); // Refresh UI
    } catch (e) {
      await _photoRepository.updatePhotoStatus(photoId, PhotoStatus.error);
      await loadPhotos();
    }
  }

  /// Supprimer une photo
  Future<void> deletePhoto(String photoId) async {
    try {
      // Supprimer du cache
      await _cacheService.deleteCachedPhoto(photoId);

      // Supprimer du repository
      await _photoRepository.deletePhoto(photoId);

      // Refresh
      await loadPhotos();
    } catch (e) {
      state = state.copyWith(error: 'Erreur lors de la suppression');
    }
  }

  /// Supprimer toutes les photos
  Future<void> deleteAllPhotos() async {
    try {
      await _cacheService.clearAllCache();
      await _photoRepository.deleteAllPhotos();
      await loadPhotos();
    } catch (e) {
      state = state.copyWith(error: 'Erreur lors de la suppression');
    }
  }

  /// Nettoyer le cache ancien
  Future<void> clearOldCache({int daysToKeep = 30}) async {
    try {
      await _photoRepository.clearOldCache(daysToKeep: daysToKeep);
      await loadPhotos();
    } catch (e) {
      state = state.copyWith(error: 'Erreur lors du nettoyage');
    }
  }

  /// Récupérer le chemin local d'une photo (si en cache)
  Future<String?> getLocalPhotoPath(String photoId) async {
    return await _cacheService.getCachedPhotoPath(photoId);
  }
}
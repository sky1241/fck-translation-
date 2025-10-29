import '../data/models/photo_gallery_item.dart';

abstract class IPhotoRepository {
  /// Sauvegarder une photo dans la galerie
  Future<void> savePhoto(PhotoGalleryItem photo);

  /// Récupérer toutes les photos (triées par date, plus récent en premier)
  Future<List<PhotoGalleryItem>> getAllPhotos();

  /// Récupérer les photos d'une journée spécifique
  Future<List<PhotoGalleryItem>> getPhotosByDate(DateTime date);

  /// Supprimer une photo
  Future<void> deletePhoto(String photoId);

  /// Supprimer toutes les photos
  Future<void> deleteAllPhotos();

  /// Mettre à jour le status d'une photo
  Future<void> updatePhotoStatus(String photoId, PhotoStatus status, {String? localPath});

  /// Récupérer une photo par son ID
  Future<PhotoGalleryItem?> getPhotoById(String photoId);

  /// Compter le nombre total de photos
  Future<int> getPhotosCount();

  /// Libérer l'espace (supprimer les vieilles photos en cache)
  Future<void> clearOldCache({int daysToKeep = 30});
}


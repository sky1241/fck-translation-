import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo_gallery_item.freezed.dart';
part 'photo_gallery_item.g.dart';

enum PhotoStatus {
  cached,      // Photo en cache local
  remote,      // Photo sur serveur uniquement
  downloading, // En cours de téléchargement
  error        // Erreur de téléchargement
}

@freezed
class PhotoGalleryItem with _$PhotoGalleryItem {
  const factory PhotoGalleryItem({
    required String id,
    required String url,              // URL cloud
    String? localPath,                // Chemin local (cache)
    required DateTime timestamp,
    required bool isFromMe,           // Photo envoyée par moi ou reçue
    String? thumbnail,                // URL du thumbnail
    int? fileSize,                    // Taille en bytes
    @Default(PhotoStatus.remote) PhotoStatus status,
  }) = _PhotoGalleryItem;

  factory PhotoGalleryItem.fromJson(Map<String, dynamic> json) =>
      _$PhotoGalleryItemFromJson(json);
}


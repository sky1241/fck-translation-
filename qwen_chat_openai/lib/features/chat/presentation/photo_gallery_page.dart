import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'photo_gallery_controller.dart';
import 'widgets/photo_grid.dart';
import '../data/models/photo_gallery_item.dart';

class PhotoGalleryPage extends ConsumerStatefulWidget {
  const PhotoGalleryPage({super.key});

  @override
  ConsumerState<PhotoGalleryPage> createState() => _PhotoGalleryPageState();
}

class _PhotoGalleryPageState extends ConsumerState<PhotoGalleryPage> {
  @override
  void initState() {
    super.initState();
    // Charger les photos au démarrage
    Future.microtask(() {
      ref.read(photoGalleryControllerProvider.notifier).loadPhotos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final PhotoGalleryState state = ref.watch(photoGalleryControllerProvider);
    final PhotoGalleryController controller = ref.watch(photoGalleryControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Galerie de Photos'),
        actions: [
          // Info sur le cache
          if (state.photos.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${state.totalCount} photos • ${state.cacheSize}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          // Menu actions
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'delete_all') {
                _showDeleteAllDialog();
              } else if (value == 'clear_cache') {
                await controller.clearOldCache(daysToKeep: 30);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cache nettoyé')),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_cache',
                child: Row(
                  children: [
                    Icon(Icons.cleaning_services),
                    SizedBox(width: 8),
                    Text('Nettoyer le cache'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Tout supprimer', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(state, controller),
    );
  }

  Widget _buildBody(PhotoGalleryState state, PhotoGalleryController controller) {
    if (state.isLoading && state.photos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.loadPhotos(),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (state.photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Aucune photo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Les photos envoyées et reçues\napparaîtront ici',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      );
    }

    // Grouper les photos par date
    final photosByDate = _groupPhotosByDate(state.photos);

    return RefreshIndicator(
      onRefresh: () => controller.loadPhotos(),
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: photosByDate.length,
        itemBuilder: (context, index) {
          final entry = photosByDate.entries.elementAt(index);
          final date = entry.key;
          final photos = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Séparateur de date
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Text(
                  _formatDate(date),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              // Grille de photos
              PhotoGrid(
                photos: photos,
                onPhotoTap: (photo) {
                  final initialIndex = state.photos.indexWhere((p) => p.id == photo.id);
                  _showPhotoViewer(context, state.photos, initialIndex >= 0 ? initialIndex : 0);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  /// Grouper les photos par date
  Map<DateTime, List<PhotoGalleryItem>> _groupPhotosByDate(List<PhotoGalleryItem> photos) {
    final Map<DateTime, List<PhotoGalleryItem>> grouped = {};

    for (final photo in photos) {
      final date = DateTime(
        photo.timestamp.year,
        photo.timestamp.month,
        photo.timestamp.day,
      );

      if (grouped[date] == null) {
        grouped[date] = [];
      }
      grouped[date]!.add(photo);
    }

    return grouped;
  }

  /// Formater une date (ex: "Aujourd'hui", "Hier", "18 Octobre 2025")
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return "Aujourd'hui";
    } else if (date == yesterday) {
      return 'Hier';
    } else {
      return DateFormat('d MMMM yyyy', 'fr').format(date);
    }
  }

  /// Afficher le viewer plein écran avec le package photo_view
  void _showPhotoViewer(BuildContext context, List<PhotoGalleryItem> photos, int initialIndex) {
    print('[PhotoGalleryPage] 🖼️ Opening PhotoViewGallery with ${photos.length} photos, index $initialIndex');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text('${initialIndex + 1} / ${photos.length}'),
          ),
          body: PhotoViewGallery.builder(
            itemCount: photos.length,
            pageController: PageController(initialPage: initialIndex),
            builder: (context, index) {
              final photo = photos[index];
              print('[PhotoViewGallery] 📸 Building item $index - photo ${photo.id}');
              print('[PhotoViewGallery] 🔍 photo.url length: ${photo.url.length} chars');
              print('[PhotoViewGallery] 🔍 photo.url starts with: ${photo.url.substring(0, photo.url.length > 50 ? 50 : photo.url.length)}');
              print('[PhotoViewGallery] 🔍 photo.thumbnail: ${photo.thumbnail != null ? "exists (${photo.thumbnail!.length} chars)" : "null"}');
              
              // Priorité : url (base64 JPEG) > thumbnail
              final String imageSource = photo.url.isNotEmpty ? photo.url : (photo.thumbnail ?? '');
              
              // Décoder le base64 JPEG
              Uint8List? imageBytes;
              if (imageSource.startsWith('data:image/')) {
                try {
                  final base64Data = imageSource.split(',').last;
                  imageBytes = base64Decode(base64Data);
                  print('[PhotoViewGallery] ✅ Decoded ${imageBytes.length} bytes for photo $index');
                } catch (e) {
                  print('[PhotoViewGallery] ❌ Failed to decode base64: $e');
                }
              } else {
                print('[PhotoViewGallery] ⚠️ imageSource does not start with data:image/ : $imageSource');
              }
              
              // Fallback : icon si pas d'image
              if (imageBytes == null) {
                print('[PhotoViewGallery] ⚠️ No valid image bytes, showing error icon');
                return PhotoViewGalleryPageOptions.customChild(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.broken_image, size: 100, color: Colors.white54),
                        const SizedBox(height: 16),
                        Text(
                          'Image non disponible\n${photo.id}',
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  heroAttributes: PhotoViewHeroAttributes(tag: photo.id),
                );
              }
              
              return PhotoViewGalleryPageOptions(
                imageProvider: MemoryImage(imageBytes),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                heroAttributes: PhotoViewHeroAttributes(tag: photo.id),
                errorBuilder: (context, error, stackTrace) {
                  print('[PhotoViewGallery] ❌ MemoryImage error: $error');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 100, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Erreur d\'affichage\n$error',
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            loadingBuilder: (context, event) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Afficher la confirmation de suppression
  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer toutes les photos ?'),
        content: const Text(
          'Cette action est irréversible. Toutes les photos seront supprimées de la galerie et du cache.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(photoGalleryControllerProvider.notifier)
                  .deleteAllPhotos();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Toutes les photos supprimées')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}


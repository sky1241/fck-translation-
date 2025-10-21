import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'photo_gallery_controller.dart';
import 'widgets/photo_grid.dart';
import 'widgets/photo_viewer.dart';
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
    final state = ref.watch(photoGalleryControllerProvider);
    final controller = ref.watch(photoGalleryControllerProvider.notifier);

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PhotoViewer(
                        initialPhotoId: photo.id,
                        allPhotos: state.photos,
                      ),
                    ),
                  );
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


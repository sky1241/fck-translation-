import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models/photo_gallery_item.dart';
import '../photo_gallery_controller.dart';
import 'base64_image_widget.dart';

class PhotoViewer extends ConsumerStatefulWidget {
  final String initialPhotoId;
  final List<PhotoGalleryItem> allPhotos;

  const PhotoViewer({
    super.key,
    required this.initialPhotoId,
    required this.allPhotos,
  });

  @override
  ConsumerState<PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends ConsumerState<PhotoViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.allPhotos.indexWhere((p) => p.id == widget.initialPhotoId);
    if (_currentIndex == -1) _currentIndex = 0;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('[PhotoViewer] build() called, currentIndex: $_currentIndex, totalPhotos: ${widget.allPhotos.length}');
    
    if (widget.allPhotos.isEmpty) {
      print('[PhotoViewer] ERROR: allPhotos is empty!');
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: const Center(child: Text('Aucune photo')),
      );
    }
    
    if (_currentIndex < 0 || _currentIndex >= widget.allPhotos.length) {
      print('[PhotoViewer] ERROR: Invalid currentIndex: $_currentIndex');
      _currentIndex = 0;
    }
    
    final currentPhoto = widget.allPhotos[_currentIndex];
    print('[PhotoViewer] Current photo ID: ${currentPhoto.id}');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_currentIndex + 1} / ${widget.allPhotos.length}'),
        actions: [
          // Télécharger
          if (currentPhoto.status != PhotoStatus.cached)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _downloadPhoto(currentPhoto),
            ),
          // Menu actions
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _deletePhoto(currentPhoto);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Supprimer', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // PageView avec les photos
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.allPhotos.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return _buildPhotoView(widget.allPhotos[index]);
              },
            ),
          ),
          
          // Info en bas
          Container(
            color: Colors.black,
            padding: const EdgeInsets.all(16),
            child: _buildPhotoInfo(currentPhoto),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoView(PhotoGalleryItem photo) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: _buildImage(photo),
      ),
    );
  }

  Widget _buildImage(PhotoGalleryItem photo) {
    try {
      print('[PhotoViewer] Loading photo: ${photo.id}');
      print('[PhotoViewer]   - localPath: ${photo.localPath}');
      final urlPreview = photo.url.length > 100 ? '${photo.url.substring(0, 100)}...' : photo.url;
      print('[PhotoViewer]   - url: $urlPreview');
      print('[PhotoViewer]   - status: ${photo.status}');
      
      // Si photo en cache local ET le fichier existe vraiment
      if (photo.localPath != null) {
        try {
          final file = File(photo.localPath!);
          if (file.existsSync()) {
            print('[PhotoViewer] Using local file');
            return Image.file(
              file,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                print('[PhotoViewer] Local file error: $error');
                // Fallback to URL/base64
                return Base64ImageWidget(
                  imageSource: photo.url,
                  fit: BoxFit.contain,
                );
              },
            );
          } else {
            print('[PhotoViewer] Local file does not exist');
          }
        } catch (e) {
          print('[PhotoViewer] Error checking local file: $e');
        }
      }
      
      // Sinon, afficher depuis URL ou base64
      print('[PhotoViewer] Using URL/base64');
      return Base64ImageWidget(
        imageSource: photo.url,
        fit: BoxFit.contain,
      );
    } catch (e) {
      print('[PhotoViewer] CRITICAL ERROR in _buildImage: $e');
      return Container(
        color: Colors.red,
        child: const Center(
          child: Icon(Icons.error, color: Colors.white, size: 48),
        ),
      );
    }
  }

  Widget _buildError() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoInfo(PhotoGalleryItem photo) {
    final dateFormat = DateFormat('d MMMM yyyy • HH:mm', 'fr');
    final sizeText = photo.fileSize != null
        ? _formatFileSize(photo.fileSize!)
        : 'Taille inconnue';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              photo.isFromMe ? Icons.send : Icons.download,
              size: 16,
              color: Colors.grey.shade400,
            ),
            const SizedBox(width: 8),
            Text(
              photo.isFromMe ? 'Envoyée' : 'Reçue',
              style: TextStyle(color: Colors.grey.shade400),
            ),
            const Spacer(),
            Text(
              dateFormat.format(photo.timestamp),
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          sizeText,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
        ),
      ],
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  Future<void> _downloadPhoto(PhotoGalleryItem photo) async {
    final controller = ref.read(photoGalleryControllerProvider.notifier);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Téléchargement en cours...')),
    );
    
    await controller.downloadPhoto(photo.id, photo.url);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo téléchargée')),
      );
    }
  }

  Future<void> _deletePhoto(PhotoGalleryItem photo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette photo ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final controller = ref.read(photoGalleryControllerProvider.notifier);
      await controller.deletePhoto(photo.id);
      
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}


import 'dart:io';

import 'package:flutter/material.dart';

import '../../data/models/photo_gallery_item.dart';
import 'base64_image_widget.dart';

class PhotoGridItem extends StatelessWidget {
  final PhotoGalleryItem photo;
  final VoidCallback onTap;

  const PhotoGridItem({
    super.key,
    required this.photo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          _buildImage(),
          
          // Overlay si téléchargement en cours
          if (photo.status == PhotoStatus.downloading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
          
          // Icône d'erreur
          if (photo.status == PhotoStatus.error)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          
          // Badge "de moi" ou "reçue"
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: photo.isFromMe ? Colors.blue : Colors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                photo.isFromMe ? Icons.send : Icons.download,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    // Si photo en cache local
    if (photo.localPath != null && File(photo.localPath!).existsSync()) {
      return Image.file(
        File(photo.localPath!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }
    
    // Sinon, afficher depuis URL ou base64 (thumbnail ou original)
    final imageUrl = photo.thumbnail ?? photo.url;
    
    return Base64ImageWidget(
      imageSource: imageUrl,
      fit: BoxFit.cover,
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(Icons.photo, size: 32, color: Colors.grey),
      ),
    );
  }
}


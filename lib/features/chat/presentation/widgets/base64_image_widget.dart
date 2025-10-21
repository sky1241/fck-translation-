import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Widget qui affiche une image depuis une URL ou du base64
class Base64ImageWidget extends StatelessWidget {
  final String imageSource;
  final BoxFit fit;
  final double? width;
  final double? height;

  const Base64ImageWidget({
    super.key,
    required this.imageSource,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Vérifier si c'est du base64
    if (imageSource.startsWith('data:image')) {
      try {
        // Extraire les données base64
        final base64Data = imageSource.split(',').last;
        final Uint8List bytes = base64Decode(base64Data);
        
        return Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) {
            print('[Base64ImageWidget] Error decoding base64: $error');
            return _buildErrorWidget();
          },
        );
      } catch (e) {
        print('[Base64ImageWidget] Failed to decode base64: $e');
        return _buildErrorWidget();
      }
    } else {
      // URL normale
      return Image.network(
        imageSource,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('[Base64ImageWidget] Error loading image: $error');
          return _buildErrorWidget();
        },
      );
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Icon(
        Icons.broken_image,
        color: Colors.grey,
        size: 48,
      ),
    );
  }
}


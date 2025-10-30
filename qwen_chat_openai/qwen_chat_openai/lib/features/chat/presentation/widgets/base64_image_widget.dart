import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
// BUILD 2025-10-25 FIX FINAL - gaplessPlayback + filterQuality + logs détaillés
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
    if (kDebugMode) debugPrint('[Base64ImageWidget] build() - imageSource length: ${imageSource.length}');
    if (kDebugMode) debugPrint('[Base64ImageWidget] imageSource starts with: ${imageSource.substring(0, imageSource.length > 50 ? 50 : imageSource.length)}');
    
    // Vérifier si c'est du base64
    if (imageSource.startsWith('data:image')) {
      try {
        if (kDebugMode) debugPrint('[Base64ImageWidget] Detected base64 data');
        // Extraire les données base64
        final parts = imageSource.split(',');
        if (parts.length < 2) {
          if (kDebugMode) debugPrint('[Base64ImageWidget] ERROR: Invalid base64 format (no comma)');
          return _buildErrorWidget('Format base64 invalide');
        }
        
        final base64Data = parts.last;
        if (kDebugMode) debugPrint('[Base64ImageWidget] Base64 data length: ${base64Data.length}');
        
        final Uint8List bytes = base64Decode(base64Data);
        if (kDebugMode) debugPrint('[Base64ImageWidget] ✅ Decoded ${bytes.length} bytes');
        
        return Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          gaplessPlayback: true,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) {
            if (kDebugMode) debugPrint('[Base64ImageWidget] ❌ Image.memory error: $error');
            if (kDebugMode) debugPrint('[Base64ImageWidget] ❌ First 100 bytes: ${bytes.take(100).toList()}');
            if (kDebugMode) debugPrint('[Base64ImageWidget] Stack: $stackTrace');
            return _buildErrorWidget('Erreur affichage: $error');
          },
        );
      } catch (e, stack) {
        if (kDebugMode) debugPrint('[Base64ImageWidget] ❌ Failed to decode base64: $e');
        if (kDebugMode) debugPrint('[Base64ImageWidget] Stack: $stack');
        return _buildErrorWidget('Décodage échoué: $e');
      }
    } else if (imageSource.startsWith('http://') || imageSource.startsWith('https://')) {
      // URL normale
      if (kDebugMode) debugPrint('[Base64ImageWidget] Using network URL');
      return Image.network(
        imageSource,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            if (kDebugMode) debugPrint('[Base64ImageWidget] ✅ Image loaded from network');
            return child;
          }
          if (kDebugMode) debugPrint('[Base64ImageWidget] Loading... ${loadingProgress.cumulativeBytesLoaded} / ${loadingProgress.expectedTotalBytes ?? "?"}');
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          if (kDebugMode) debugPrint('[Base64ImageWidget] ❌ Network error: $error');
          return _buildErrorWidget('Erreur réseau: $error');
        },
      );
    } else {
      // Source inconnue
      if (kDebugMode) debugPrint('[Base64ImageWidget] ⚠️ Unknown image source type: $imageSource');
      return _buildErrorWidget('Type source inconnu');
    }
  }

  Widget _buildErrorWidget([String? message]) {
    return Container(
      width: width,
      height: height,
      color: Colors.red[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.broken_image,
            color: Colors.red,
            size: 48,
          ),
          if (message != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}


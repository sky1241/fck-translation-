import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PhotoCacheService {
  /// Télécharger et cacher une photo
  Future<String?> cachePhoto(String url, String photoId) async {
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode != 200) {
        return null;
      }
      
      final bytes = response.bodyBytes;
      final localPath = await _saveToCache(photoId, bytes, 'original');
      
      return localPath;
    } catch (e) {
      return null;
    }
  }

  /// Télécharger et cacher un thumbnail
  Future<String?> cacheThumbnail(String url, String photoId) async {
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode != 200) {
        return null;
      }
      
      final bytes = response.bodyBytes;
      final localPath = await _saveToCache(photoId, bytes, 'thumbnail');
      
      return localPath;
    } catch (e) {
      return null;
    }
  }

  /// Sauvegarder bytes dans le cache
  Future<String> _saveToCache(String photoId, Uint8List bytes, String type) async {
    final cacheDir = await getTemporaryDirectory();
    final photoDir = Directory('${cacheDir.path}/photos/$type');
    
    if (!await photoDir.exists()) {
      await photoDir.create(recursive: true);
    }
    
    final file = File('${photoDir.path}/$photoId.jpg');
    await file.writeAsBytes(bytes);
    
    return file.path;
  }

  /// Vérifier si une photo est en cache
  Future<bool> isPhotoCached(String photoId) async {
    final cacheDir = await getTemporaryDirectory();
    final file = File('${cacheDir.path}/photos/original/$photoId.jpg');
    return await file.exists();
  }

  /// Récupérer le chemin local d'une photo en cache
  Future<String?> getCachedPhotoPath(String photoId) async {
    final cacheDir = await getTemporaryDirectory();
    final file = File('${cacheDir.path}/photos/original/$photoId.jpg');
    
    if (await file.exists()) {
      return file.path;
    }
    
    return null;
  }

  /// Récupérer le chemin local d'un thumbnail en cache
  Future<String?> getCachedThumbnailPath(String photoId) async {
    final cacheDir = await getTemporaryDirectory();
    final file = File('${cacheDir.path}/photos/thumbnail/$photoId.jpg');
    
    if (await file.exists()) {
      return file.path;
    }
    
    return null;
  }

  /// Supprimer une photo du cache
  Future<void> deleteCachedPhoto(String photoId) async {
    final cacheDir = await getTemporaryDirectory();
    
    // Supprimer l'original
    final originalFile = File('${cacheDir.path}/photos/original/$photoId.jpg');
    if (await originalFile.exists()) {
      await originalFile.delete();
    }
    
    // Supprimer le thumbnail
    final thumbFile = File('${cacheDir.path}/photos/thumbnail/$photoId.jpg');
    if (await thumbFile.exists()) {
      await thumbFile.delete();
    }
  }

  /// Nettoyer tout le cache
  Future<void> clearAllCache() async {
    final cacheDir = await getTemporaryDirectory();
    final photoDir = Directory('${cacheDir.path}/photos');
    
    if (await photoDir.exists()) {
      await photoDir.delete(recursive: true);
    }
  }

  /// Calculer la taille du cache en bytes
  Future<int> getCacheSize() async {
    final cacheDir = await getTemporaryDirectory();
    final photoDir = Directory('${cacheDir.path}/photos');
    
    if (!await photoDir.exists()) {
      return 0;
    }
    
    int totalSize = 0;
    await for (final entity in photoDir.list(recursive: true)) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
    
    return totalSize;
  }

  /// Formater la taille du cache (ex: "12.5 MB")
  String formatCacheSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}


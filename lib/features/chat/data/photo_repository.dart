import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/i_photo_repository.dart';
import 'models/photo_gallery_item.dart';

class PhotoRepository implements IPhotoRepository {
  static const String _storageKey = 'photo_gallery_v1';

  @override
  Future<void> savePhoto(PhotoGalleryItem photo) async {
    print('[PhotoRepository] 🔵 savePhoto called: ${photo.id}');
    print('[PhotoRepository]    - url: ${photo.url}');
    print('[PhotoRepository]    - localPath: ${photo.localPath}');
    print('[PhotoRepository]    - isFromMe: ${photo.isFromMe}');
    
    final sp = await SharedPreferences.getInstance();
    print('[PhotoRepository] ✅ SharedPreferences loaded');
    
    final photos = await getAllPhotos();
    print('[PhotoRepository] 📦 Current photos: ${photos.length}');
    
    // Vérifier si la photo existe déjà
    final index = photos.indexWhere((p) => p.id == photo.id);
    if (index != -1) {
      // Mettre à jour
      photos[index] = photo;
      print('[PhotoRepository] 🔄 Photo updated at index $index');
    } else {
      // Ajouter
      photos.add(photo);
      print('[PhotoRepository] ➕ Photo added, total: ${photos.length}');
    }
    
    // Trier par date (plus récent en premier)
    photos.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    // Sauvegarder
    final json = photos.map((p) => p.toJson()).toList();
    print('[PhotoRepository] 📝 JSON created: ${json.length} items');
    
    await sp.setString(_storageKey, jsonEncode(json));
    print('[PhotoRepository] ✅ Saved to SharedPreferences (key: $_storageKey)');
    
    // Vérifier immédiatement la sauvegarde
    final savedData = sp.getString(_storageKey);
    print('[PhotoRepository] 🔍 Verification: saved data length = ${savedData?.length ?? 0}');
  }

  @override
  Future<List<PhotoGalleryItem>> getAllPhotos() async {
    print('[PhotoRepository] 🔵 getAllPhotos called');
    final sp = await SharedPreferences.getInstance();
    final data = sp.getString(_storageKey);
    
    if (data == null) {
      print('[PhotoRepository] ⚠️ No data in SharedPreferences (key: $_storageKey)');
      return [];
    }
    
    print('[PhotoRepository] 📦 Raw data length: ${data.length}');
    
    try {
      final List<dynamic> jsonList = jsonDecode(data) as List<dynamic>;
      print('[PhotoRepository] 📝 JSON decoded: ${jsonList.length} items');
      
      final photos = jsonList
          .map((json) => PhotoGalleryItem.fromJson(json as Map<String, dynamic>))
          .toList();
      
      print('[PhotoRepository] ✅ Returning ${photos.length} photos');
      return photos;
    } catch (e) {
      // Si erreur de parsing, retourner liste vide
      print('[PhotoRepository] ❌ Error parsing JSON: $e');
      return [];
    }
  }

  @override
  Future<List<PhotoGalleryItem>> getPhotosByDate(DateTime date) async {
    final all = await getAllPhotos();
    
    // Filtrer par même jour
    return all.where((photo) {
      final photoDate = photo.timestamp;
      return photoDate.year == date.year &&
          photoDate.month == date.month &&
          photoDate.day == date.day;
    }).toList();
  }

  @override
  Future<void> deletePhoto(String photoId) async {
    final photos = await getAllPhotos();
    photos.removeWhere((p) => p.id == photoId);
    
    final sp = await SharedPreferences.getInstance();
    final json = photos.map((p) => p.toJson()).toList();
    await sp.setString(_storageKey, jsonEncode(json));
  }

  @override
  Future<void> deleteAllPhotos() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_storageKey);
  }

  @override
  Future<void> updatePhotoStatus(
    String photoId,
    PhotoStatus status, {
    String? localPath,
  }) async {
    final photos = await getAllPhotos();
    final index = photos.indexWhere((p) => p.id == photoId);
    
    if (index != -1) {
      photos[index] = photos[index].copyWith(
        status: status,
        localPath: localPath ?? photos[index].localPath,
      );
      
      final sp = await SharedPreferences.getInstance();
      final json = photos.map((p) => p.toJson()).toList();
      await sp.setString(_storageKey, jsonEncode(json));
    }
  }

  @override
  Future<PhotoGalleryItem?> getPhotoById(String photoId) async {
    final photos = await getAllPhotos();
    try {
      return photos.firstWhere((p) => p.id == photoId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> getPhotosCount() async {
    final photos = await getAllPhotos();
    return photos.length;
  }

  @override
  Future<void> clearOldCache({int daysToKeep = 30}) async {
    final photos = await getAllPhotos();
    final now = DateTime.now();
    final cutoffDate = now.subtract(Duration(days: daysToKeep));
    
    // Garder seulement les photos récentes
    final recentPhotos = photos.where((photo) {
      return photo.timestamp.isAfter(cutoffDate);
    }).toList();
    
    final sp = await SharedPreferences.getInstance();
    final json = recentPhotos.map((p) => p.toJson()).toList();
    await sp.setString(_storageKey, jsonEncode(json));
  }
}


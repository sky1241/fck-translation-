import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

class PermissionService {
  /// Demander toutes les permissions nécessaires au démarrage
  static Future<void> requestAllPermissions() async {
    if (kDebugMode) debugPrint('[PermissionService] 🔐 Requesting permissions...');
    
    // 1. Permission pour les notifications (Android 13+)
    final notificationStatus = await Permission.notification.request();
    if (kDebugMode) debugPrint('[PermissionService] Notification permission: $notificationStatus');
    
    // 2. Permission pour les photos
    // Sur Android 13+, utilise READ_MEDIA_IMAGES
    // Sur Android <13, utilise READ_EXTERNAL_STORAGE
    final photoStatus = await Permission.photos.request();
    if (kDebugMode) debugPrint('[PermissionService] Photos permission: $photoStatus');
    
    // Alternative si photos ne marche pas : demander storage sur anciennes versions
    if (photoStatus.isDenied) {
      final storageStatus = await Permission.storage.request();
      if (kDebugMode) debugPrint('[PermissionService] Storage permission: $storageStatus');
    }
    
    if (kDebugMode) debugPrint('[PermissionService] ✅ Permissions requested');
  }
  
  /// Vérifier si on a les permissions
  static Future<bool> hasAllPermissions() async {
    final hasNotif = await Permission.notification.isGranted;
    final hasPhotos = await Permission.photos.isGranted || await Permission.storage.isGranted;
    
    if (kDebugMode) debugPrint('[PermissionService] Has notification: $hasNotif');
    if (kDebugMode) debugPrint('[PermissionService] Has photos: $hasPhotos');
    
    return hasNotif && hasPhotos;
  }
  
  /// Ouvrir les paramètres si permissions refusées
  static Future<void> openSettings() async {
    if (kDebugMode) debugPrint('[PermissionService] Opening app settings...');
    await openAppSettings();
  }
}


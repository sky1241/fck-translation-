import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Demander toutes les permissions nécessaires au démarrage
  static Future<void> requestAllPermissions() async {
    print('[PermissionService] 🔐 Requesting permissions...');
    
    // 1. Permission pour les notifications (Android 13+)
    final notificationStatus = await Permission.notification.request();
    print('[PermissionService] Notification permission: $notificationStatus');
    
    // 2. Permission pour les photos
    // Sur Android 13+, utilise READ_MEDIA_IMAGES
    // Sur Android <13, utilise READ_EXTERNAL_STORAGE
    final photoStatus = await Permission.photos.request();
    print('[PermissionService] Photos permission: $photoStatus');
    
    // Alternative si photos ne marche pas : demander storage sur anciennes versions
    if (photoStatus.isDenied) {
      final storageStatus = await Permission.storage.request();
      print('[PermissionService] Storage permission: $storageStatus');
    }
    
    print('[PermissionService] ✅ Permissions requested');
  }
  
  /// Vérifier si on a les permissions
  static Future<bool> hasAllPermissions() async {
    final hasNotif = await Permission.notification.isGranted;
    final hasPhotos = await Permission.photos.isGranted || await Permission.storage.isGranted;
    
    print('[PermissionService] Has notification: $hasNotif');
    print('[PermissionService] Has photos: $hasPhotos');
    
    return hasNotif && hasPhotos;
  }
  
  /// Ouvrir les paramètres si permissions refusées
  static Future<void> openSettings() async {
    print('[PermissionService] Opening app settings...');
    await openAppSettings();
  }
}


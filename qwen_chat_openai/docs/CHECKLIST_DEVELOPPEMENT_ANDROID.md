# ⚠️ CHECKLIST CRITIQUE - DÉVELOPPEMENT ANDROID

## 🚨 À VÉRIFIER **AVANT** DE CODER QUOI QUE CE SOIT

**Cette checklist DOIT être suivie pour CHAQUE nouvelle feature Android.**

---

## 📱 PERMISSIONS ANDROID - RÈGLE D'OR

### ⚠️ RÈGLE ABSOLUE
**Si tu utilises une ressource sensible → Tu DOIS demander la permission au runtime**

### 📋 Checklist Permissions

**AVANT de coder une feature, pose-toi ces questions :**

#### 1. Est-ce que ma feature utilise :
- [ ] 📷 **Photos/Images** → Permission `READ_MEDIA_IMAGES` (Android 13+) + `READ_EXTERNAL_STORAGE` (<13)
- [ ] 🔔 **Notifications** → Permission `POST_NOTIFICATIONS` (Android 13+)
- [ ] 📹 **Caméra** → Permission `CAMERA`
- [ ] 🎤 **Microphone** → Permission `RECORD_AUDIO`
- [ ] 📍 **Localisation** → Permission `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION`
- [ ] 📞 **Téléphone** → Permission `CALL_PHONE`
- [ ] 💾 **Stockage** → Permission `WRITE_EXTERNAL_STORAGE` (<10)
- [ ] 📱 **Contacts** → Permission `READ_CONTACTS`

#### 2. Si OUI à une de ces questions :
1. ✅ **Déclarer la permission dans `AndroidManifest.xml`**
2. ✅ **Créer/utiliser un service de permissions**
3. ✅ **Demander la permission au runtime**
4. ✅ **Tester sur un vrai device** (pas juste l'émulateur)
5. ✅ **Vérifier les logs** que la permission est accordée

#### 3. JAMAIS faire :
- ❌ Coder une feature sans vérifier les permissions
- ❌ Supposer que déclarer dans AndroidManifest suffit
- ❌ Builder sans tester les permissions
- ❌ Oublier les différentes versions Android (13+ vs <13)

---

## 🎯 EXEMPLE : GALERIE PHOTO

### ❌ MAUVAISE APPROCHE (ce qui a été fait)
```
1. Créer PhotoRepository
2. Créer PhotoGalleryPage
3. Builder l'app
4. "Pourquoi la galerie est vide ?" → 2h de debug
5. Découvrir qu'on a oublié les permissions
```

### ✅ BONNE APPROCHE (ce qu'il fallait faire)
```
1. Feature : Galerie photo
2. ⚠️ STOP → Checker les permissions nécessaires
3. Ajouter permissions dans AndroidManifest.xml
4. Créer PermissionService
5. Demander permissions au démarrage
6. ENSUITE créer PhotoRepository
7. ENSUITE créer PhotoGalleryPage
8. Tester sur device réel
9. Vérifier dans les logs que permissions sont accordées
10. Builder
```

---

## 📝 TEMPLATE PermissionService

**Pour TOUTE nouvelle app Android, créer ce service :**

```dart
// lib/core/permissions/permission_service.dart
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Demander toutes les permissions nécessaires
  static Future<void> requestAllPermissions() async {
    print('[PermissionService] 🔐 Requesting permissions...');
    
    // Liste des permissions selon la feature
    final permissions = [
      Permission.photos,           // Pour galerie photo
      Permission.notification,     // Pour notifications
      // Ajouter d'autres selon besoin
    ];
    
    for (final permission in permissions) {
      final status = await permission.request();
      print('[PermissionService] $permission: $status');
    }
    
    print('[PermissionService] ✅ Permissions requested');
  }
  
  /// Vérifier si on a toutes les permissions
  static Future<bool> hasAllPermissions() async {
    final hasPhotos = await Permission.photos.isGranted;
    final hasNotif = await Permission.notification.isGranted;
    
    print('[PermissionService] Has photos: $hasPhotos');
    print('[PermissionService] Has notif: $hasNotif');
    
    return hasPhotos && hasNotif;
  }
  
  /// Ouvrir les paramètres
  static Future<void> openSettings() async {
    await openAppSettings();
  }
}
```

**Et l'appeler dans `main.dart` :**

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ TOUJOURS demander les permissions au démarrage
  try {
    await PermissionService.requestAllPermissions();
  } catch (e) {
    print('⚠️ Error requesting permissions: $e');
  }
  
  runApp(const MyApp());
}
```

---

## 📦 DEPENDENCIES ESSENTIELLES

**Ajouter dans `pubspec.yaml` :**

```yaml
dependencies:
  permission_handler: ^11.3.1  # Pour gérer les permissions
```

**AndroidManifest.xml - Template de base :**

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Internet (toujours nécessaire) -->
    <uses-permission android:name="android.permission.INTERNET" />
    
    <!-- Notifications (Android 13+) -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    
    <!-- Photos (adapter selon version Android) -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" 
                     android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
                     android:maxSdkVersion="28" />
    
    <application ...>
        ...
    </application>
</manifest>
```

---

## 🔧 WORKFLOW DE DÉVELOPPEMENT

### Phase 1 : PLANIFICATION (avant tout code)
1. ✅ Lire les specs/besoins
2. ✅ Identifier les permissions nécessaires
3. ✅ Créer la checklist des permissions
4. ✅ Préparer AndroidManifest.xml
5. ✅ Créer/mettre à jour PermissionService

### Phase 2 : DÉVELOPPEMENT
6. ✅ Coder les features
7. ✅ Ajouter logs partout
8. ✅ Tester sur émulateur
9. ✅ **Tester sur device réel** (important!)

### Phase 3 : BUILD & TEST
10. ✅ Vérifier la clé API
11. ✅ Vérifier RELAY_ROOM (si WebSocket)
12. ✅ Vérifier APP_VERSION
13. ✅ Builder
14. ✅ Installer sur device
15. ✅ Vérifier les logs de permissions
16. ✅ Tester toutes les features
17. ✅ Valider la communication (si multi-device)

---

## 🚨 ERREURS QUI ONT FAIT PERDRE DU TEMPS

### Erreur #1 : Permissions oubliées ⏱️ 2h perdues
**Symptôme :** Galerie photo vide, notifications silencieuses  
**Cause :** Permissions déclarées mais jamais demandées au runtime  
**Solution :** PermissionService + demande au démarrage  

### Erreur #2 : RELAY_ROOM identique ⏱️ 1h perdue
**Symptôme :** Les 2 apps ne communiquent pas  
**Cause :** Les 2 versions utilisent la même room "demo123"  
**Solution :** `RELAY_ROOM=xiaoxin_001` et `RELAY_ROOM=xiaoxin_002`  

### Erreur #3 : Mauvaise clé API ⏱️ 30min perdues
**Symptôme :** Erreur 401 Unauthorized  
**Cause :** Ancienne clé API utilisée  
**Solution :** Vérifier `$env:OPENAI_API_KEY` avant CHAQUE build  

### Erreur #4 : Build sans tester ⏱️ 1h perdue
**Symptôme :** Découvrir les bugs après 2h de compilation  
**Cause :** Builder les 2 versions sans tester la première  
**Solution :** Builder UNE version → Tester → Puis builder la 2ème  

---

## ✅ CHECKLIST PRÉ-BUILD (À COCHER)

**Avant CHAQUE build, vérifier :**

```
[ ] Clé API correcte ($env:OPENAI_API_KEY)
[ ] RELAY_ROOM différente pour chaque version
[ ] APP_VERSION correcte (001 ou 002)
[ ] Permissions dans AndroidManifest.xml
[ ] PermissionService créé et appelé
[ ] Logs ajoutés partout
[ ] Code testé sur émulateur
[ ] Code testé sur device réel
[ ] Logs de permissions vérifiés
```

**Seulement SI tout est ✅ → Builder**

---

## 📊 TEMPS ESTIMÉS

| Action | Sans checklist | Avec checklist |
|--------|----------------|----------------|
| **Planification permissions** | 0 min ❌ | 10 min ✅ |
| **Debug permissions manquantes** | 120 min 😱 | 0 min 🎉 |
| **Build & test** | 180 min 😤 | 60 min ✅ |
| **Debugging post-build** | 60 min 😭 | 0 min 🎊 |
| **TOTAL** | **360 min (6h)** | **70 min (1h10)** |

**Gain de temps : 5h par projet** ⏱️

---

## 🎓 LEÇONS APPRISES

### 1. Les permissions Android ne sont PAS optionnelles
**Depuis Android 6.0 (2015), les permissions dangereuses DOIVENT être demandées au runtime.**

### 2. Déclarer ≠ Demander
**AndroidManifest.xml déclare ce que l'app PEUT utiliser.**  
**Le code Dart/Kotlin DEMANDE l'autorisation à l'utilisateur.**

### 3. Tester sur device réel
**L'émulateur peut avoir des permissions par défaut.**  
**Un vrai device montre les vrais problèmes.**

### 4. Logger tout
**Sans logs, on debug à l'aveugle.**  
**Avec logs, on voit exactement où ça bloque.**

### 5. Build incrémental
**1 version → Test → OK → 2ème version**  
**Jamais builder 2 versions sans avoir testé la 1ère**

---

## 🔗 RESSOURCES

- [Android Permissions Best Practices](https://developer.android.com/training/permissions/requesting)
- [permission_handler package](https://pub.dev/packages/permission_handler)
- [Android 13+ Permissions Changes](https://developer.android.com/about/versions/13/changes/notification-permission)

---

**Créé le :** 20 Octobre 2025  
**Raison :** Erreurs critiques sur permissions → 6h perdues  
**Objectif :** NE PLUS JAMAIS REFAIRE CES ERREURS

---

## 🎯 RÈGLE D'OR À RETENIR

> **"Feature sensible → Permissions d'abord, code ensuite"**

**Pose-toi TOUJOURS la question :**  
*"Est-ce que cette feature utilise une ressource protégée par Android ?"*

**Si OUI → Checklist permissions AVANT tout code.**

---

**⚠️ À LIRE AU DÉBUT DE CHAQUE SESSION DE DÉVELOPPEMENT ANDROID ⚠️**


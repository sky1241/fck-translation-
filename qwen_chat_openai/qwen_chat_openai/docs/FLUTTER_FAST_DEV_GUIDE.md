# ⚡ FLUTTER FAST DEV GUIDE

**Guide d'optimisation pour développement rapide d'applications Flutter**  
**Basé sur** : Projet XiaoXin002 (Octobre 2025)  
**Objectif** : Réduire de 80-90% le temps de développement sur futurs projets

---

## 🎯 OBJECTIF

Ce guide te permet de **construire une app Flutter complète en 1-2 jours** au lieu de 1-2 semaines, en évitant tous les pièges découverts sur XiaoXin002.

**Public cible** : Développement no-code/low-code avec Android Studio + AI Assistant

---

## 📋 CHECKLIST AVANT DE COMMENCER

### ✅ Pré-requis

- [ ] Flutter SDK installé (version stable)
- [ ] Android Studio + SDK Android 21-34
- [ ] ADB accessible en ligne de commande
- [ ] PowerShell 7+ (Windows) ou Bash (Linux/Mac)
- [ ] Git configuré
- [ ] Variables d'environnement pour secrets

### ✅ Configuration Initiale (30 min)

```bash
# 1. Créer projet
flutter create my_app --org com.mycompany
cd my_app

# 2. Configurer Gradle (éviter R8 deadlocks)
# Éditer android/app/build.gradle.kts
```

```kotlin
// android/app/build.gradle.kts
android {
    namespace = "com.mycompany.my_app"
    compileSdk = 34
    
    defaultConfig {
        applicationId = "com.mycompany.my_app"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }
    
    buildTypes {
        release {
            // ⚡ CRITICAL : Évite deadlocks R8 sur Windows
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("debug")  // Ou release si config
        }
    }
}
```

```bash
# 3. Configurer cache Gradle
# Éditer android/gradle.properties
```

```properties
# android/gradle.properties
org.gradle.jvmargs=-Xmx2048m -XX:+HeapDumpOnOutOfMemoryError
org.gradle.caching=true
org.gradle.parallel=true
org.gradle.daemon=true
android.useAndroidX=true
android.enableJetifier=true
```

---

## ⚡ WORKFLOW DE DÉVELOPPEMENT RAPIDE

### 1. Structure de Projet Optimale (Copy-Paste Ready)

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── env/
│   │   └── app_env.dart          # Variables d'environnement
│   ├── network/
│   │   ├── http_client.dart      # Client HTTP réutilisable
│   │   ├── notification_service.dart
│   │   └── realtime_service.dart # WebSocket si besoin
│   └── utils/
│       ├── logger.dart            # Logging robuste
│       └── json_utils.dart        # Parse JSON safe
├── features/
│   └── [feature_name]/
│       ├── data/
│       │   ├── models/           # Freezed models
│       │   ├── repositories/
│       │   └── services/
│       ├── domain/
│       │   └── interfaces/
│       └── presentation/
│           ├── pages/
│           ├── widgets/
│           └── controllers/       # Riverpod
└── shared/
    └── widgets/                   # Widgets réutilisables
```

---

### 2. Configuration Variables d'Environnement (5 min)

```dart
// lib/core/env/app_env.dart
class AppEnv {
  // Lecture depuis --dart-define
  static const String apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: '',
  );
  
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.example.com',
  );
  
  static void assertConfigured() {
    if (apiKey.isEmpty) {
      throw StateError('API_KEY non configurée !');
    }
  }
}
```

**Usage** :
```bash
flutter build apk --release \
  --dart-define=API_KEY=$env:API_KEY \
  --dart-define=API_URL=https://api.example.com
```

---

### 3. Packages Recommandés (Copy-Paste)

```yaml
# pubspec.yaml
name: my_app
description: Description de mon app
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # ⚡ State Management
  flutter_riverpod: ^2.6.1
  
  # ⚡ Network
  http: ^1.2.2
  web_socket_channel: ^3.0.3  # Si WebSocket
  
  # ⚡ Storage
  shared_preferences: ^2.4.14
  path_provider: ^2.1.4
  
  # ⚡ Notifications (Android only)
  flutter_local_notifications: ^17.2.4
  
  # ⚡ Utils
  intl: ^0.20.2                # Dates/heures
  logging: ^1.2.0              # Logs robustes
  freezed_annotation: ^2.4.4   # Models immutables
  json_annotation: ^4.9.0      # JSON
  
  # ⚡ UI (optionnel)
  flutter_svg: ^2.0.10+1       # SVG support

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  
  # Code generation
  build_runner: ^2.4.0
  freezed: ^2.5.8
  json_serializable: ^6.9.5

flutter:
  uses-material-design: true
  assets:
    - assets/
```

**Installation** :
```bash
flutter pub get
```

---

### 4. Script Build+Install Automatique (Copy-Paste)

```powershell
# scripts/deploy.ps1

param(
    [string]$Device = "all"  # "phone", "emulator", ou "all"
)

$PACKAGE = "com.mycompany.my_app"
$APK = "build\app\outputs\flutter-apk\app-release.apk"
$PHONE = "DEVICE_ID_PHONE"      # À remplacer
$EMULATOR = "emulator-5554"

Write-Host "🔨 Building APK..." -ForegroundColor Cyan

# Build incrémental (SANS flutter clean)
flutter build apk --release `
  --dart-define=API_KEY=$env:API_KEY `
  --dart-define=API_URL=$env:API_URL

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Build successful!" -ForegroundColor Green

# Fonction d'installation
function Install-OnDevice {
    param($DeviceId, $DeviceName)
    
    Write-Host "📱 Installing on $DeviceName..." -ForegroundColor Cyan
    adb -s $DeviceId install -r $APK
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Installed on $DeviceName" -ForegroundColor Green
        
        # Force restart
        adb -s $DeviceId shell am force-stop $PACKAGE
        adb -s $DeviceId shell am start -n $PACKAGE/.MainActivity
        
        Write-Host "🚀 Launched on $DeviceName" -ForegroundColor Green
    } else {
        Write-Host "❌ Install failed on $DeviceName" -ForegroundColor Red
    }
}

# Installer selon Device
switch ($Device) {
    "phone" {
        Install-OnDevice $PHONE "Phone"
    }
    "emulator" {
        Install-OnDevice $EMULATOR "Emulator"
    }
    "all" {
        Install-OnDevice $PHONE "Phone"
        Install-OnDevice $EMULATOR "Emulator"
    }
}

Write-Host "🎉 Deployment complete!" -ForegroundColor Green
```

**Usage** :
```powershell
.\scripts\deploy.ps1          # Les 2 appareils
.\scripts\deploy.ps1 -Device phone      # Téléphone seulement
.\scripts\deploy.ps1 -Device emulator   # Émulateur seulement
```

---

### 5. Service HTTP Réutilisable (Copy-Paste)

```dart
// lib/core/network/http_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class AppHttpClient {
  final Logger _log = Logger('AppHttpClient');
  final Duration timeout = const Duration(seconds: 30);
  
  Future<http.Response> postJson(
    Uri url, {
    required Map<String, String> headers,
    required Map<String, Object?> body,
  }) async {
    _log.info('POST $url');
    
    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              ...headers,
            },
            body: jsonEncode(body),
          )
          .timeout(timeout);
      
      _log.info('Response ${response.statusCode}');
      
      if (response.statusCode >= 400) {
        throw HttpException(response.statusCode, response.body);
      }
      
      return response;
    } catch (e) {
      _log.severe('HTTP Error: $e');
      rethrow;
    }
  }
  
  Future<http.Response> get(
    Uri url, {
    required Map<String, String> headers,
  }) async {
    _log.info('GET $url');
    
    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(timeout);
      
      _log.info('Response ${response.statusCode}');
      
      if (response.statusCode >= 400) {
        throw HttpException(response.statusCode, response.body);
      }
      
      return response;
    } catch (e) {
      _log.severe('HTTP Error: $e');
      rethrow;
    }
  }
}

class HttpException implements Exception {
  final int statusCode;
  final String body;
  
  HttpException(this.statusCode, this.body);
  
  @override
  String toString() => 'HTTP $statusCode: $body';
}
```

---

### 6. Service de Notifications Robuste (Copy-Paste)

```dart
// lib/core/network/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';

class NotificationService {
  final Logger _log = Logger('NotificationService');
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  
  // ⚡ VERSIONNER le canal pour forcer reset
  static const String CHANNEL_ID = 'app_notifications_v1';
  static const int SUMMARY_ID = 999999;
  
  Future<void> initialize() async {
    _log.info('Initializing notifications...');
    
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    
    try {
      await _plugin.initialize(settings);
      
      // ⚡ Créer canal explicitement avec Importance HIGH
      const channel = AndroidNotificationChannel(
        CHANNEL_ID,
        'App Notifications',
        description: 'Notifications de l\'application',
        importance: Importance.high,  // ← Pour le son
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );
      
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      
      _log.info('Notifications initialized');
    } catch (e) {
      _log.warning('Failed to initialize notifications: $e');
    }
  }
  
  Future<void> show({
    required String title,
    required String body,
    bool silent = false,
  }) async {
    final details = AndroidNotificationDetails(
      CHANNEL_ID,
      'App Notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: !silent,
      enableVibration: !silent,
      icon: '@mipmap/ic_launcher',
    );
    
    await _plugin.show(
      0,
      title,
      body,
      NotificationDetails(android: details),
    );
  }
  
  // Notification permanente (comme WhatsApp)
  Future<void> showPersistent({
    required String title,
    required String body,
    required int count,
    bool silent = false,
  }) async {
    final details = AndroidNotificationDetails(
      CHANNEL_ID,
      'App Notifications',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,  // ← Permanente
      autoCancel: false,
      number: count,
      showWhen: false,
      playSound: !silent,
      enableVibration: !silent,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );
    
    await _plugin.show(
      SUMMARY_ID,
      title,
      body,
      NotificationDetails(android: details),
    );
  }
  
  Future<void> clearPersistent() async {
    await _plugin.cancel(SUMMARY_ID);
  }
}
```

---

### 7. Logger Robuste (Copy-Paste)

```dart
// lib/core/utils/logger.dart
import 'package:logging/logging.dart';

void setupLogger() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // Format: [LEVEL] Logger: message
    print('[${record.level.name}] ${record.loggerName}: ${record.message}');
    
    if (record.error != null) {
      print('Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      print('Stack trace:\n${record.stackTrace}');
    }
  });
}
```

**Usage dans main.dart** :
```dart
// main.dart
import 'core/utils/logger.dart';

void main() {
  setupLogger();  // ← Avant runApp
  runApp(const MyApp());
}
```

---

## 🚀 WORKFLOW COMPLET (1 JOURNÉE)

### Heure 0-2 : Setup Initial

1. ✅ Créer projet : `flutter create`
2. ✅ Config Gradle (no-shrink)
3. ✅ Ajouter packages essentiels
4. ✅ Copier structure de dossiers
5. ✅ Copier templates (HTTP, Logger, Notifications)
6. ✅ Créer script deploy.ps1
7. ✅ Test build : `flutter build apk --release`

---

### Heure 2-6 : Features Core

1. ✅ Implémenter AppEnv
2. ✅ Créer models avec Freezed
3. ✅ Implémenter services (API, etc.)
4. ✅ State management avec Riverpod
5. ✅ Tests unitaires basiques

---

### Heure 6-10 : UI & UX

1. ✅ Créer pages principales
2. ✅ Widgets réutilisables
3. ✅ Navigation
4. ✅ Gestion erreurs
5. ✅ Loading states

---

### Heure 10-14 : Polish & Features Secondaires

1. ✅ Notifications
2. ✅ Stockage local (SharedPreferences)
3. ✅ Icône app
4. ✅ Splash screen
5. ✅ Tests E2E

---

### Heure 14-16 : Tests & Debug

1. ✅ Tests sur appareil réel
2. ✅ Fix bugs
3. ✅ Vérifier perfs
4. ✅ Logs en production

---

### Heure 16-18 : Déploiement

1. ✅ Build release final
2. ✅ Test installation
3. ✅ Documentation
4. ✅ Git commit/push

---

## ⚠️ PIÈGES À ÉVITER (CRITIQUES)

### 1. ❌ NE JAMAIS `flutter clean` par défaut

```bash
# ❌ NE PAS FAIRE
flutter clean && flutter build apk  # Perd 60-90 min !

# ✅ FAIRE
flutter build apk  # Build incrémental : 2-7 min
```

**Quand faire `flutter clean` ?** UNIQUEMENT si :
- Code pas dans APK après build
- Erreurs Gradle impossibles à résoudre
- Changement version majeure package

---

### 2. ❌ NE PAS utiliser packages obsolètes

**Vérifier sur pub.dev** :
- ✅ Dernière MAJ < 6 mois
- ✅ Score > 100
- ✅ Likes > 500
- ✅ Null safety

**Exemples à ÉVITER** :
- ❌ `flutter_app_badger` (obsolète)
- ❌ `fluttertoast` (utiliser SnackBar)
- ❌ Tout package avec "Last updated: 2+ years ago"

---

### 3. ❌ NE PAS utiliser `print()` en production

```dart
// ❌ NE PAS FAIRE
print('Debug message');  // Invisible en release mode

// ✅ FAIRE
Logger('MyClass').info('Debug message');  // Visible partout
```

---

### 4. ❌ NE PAS mettre secrets en dur

```dart
// ❌ NE PAS FAIRE
const apiKey = 'sk-proj-12345';  // Dans le code

// ✅ FAIRE
const apiKey = String.fromEnvironment('API_KEY');  // --dart-define
```

---

### 5. ❌ NE PAS ignorer ADB offline

```bash
# Si ADB ne voit pas les appareils :
adb kill-server
adb start-server
sleep 5
adb devices
```

---

### 6. ❌ NE PAS utiliser Importance.low pour notifications

```dart
// ❌ PAS DE SON
importance: Importance.low,

// ✅ SON ACTIVÉ
importance: Importance.high,
```

---

### 7. ❌ NE PAS oublier AndroidManifest.xml

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest>
    <!-- ⚡ Permissions essentielles -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.VIBRATE" />
    
    <application
        android:label="My App"
        android:icon="@mipmap/ic_launcher">
        <!-- ... -->
    </application>
</manifest>
```

---

## 🛠️ COMMANDES ESSENTIELLES

### Debug

```bash
# Logs en temps réel
adb logcat | Select-String -Pattern "flutter|error"

# Vérifier package installé
adb shell pm list packages | grep my.app

# Vérifier canal de notification
adb shell dumpsys notification | grep my.app

# Vérifier processus
adb shell "ps -A | grep my.app"

# Clear data (reset complet app)
adb shell pm clear com.mycompany.my_app
```

---

### Build

```bash
# Build rapide (incrémental)
flutter build apk --release

# Build avec config
flutter build apk --release \
  --dart-define=API_KEY=$env:API_KEY

# Build sans R8 shrinking
flutter build apk --release --no-shrink
```

---

### ADB

```bash
# Reset ADB
adb kill-server && adb start-server

# Lister appareils
adb devices

# Installer APK
adb install -r app.apk

# Désinstaller
adb uninstall com.mycompany.my_app

# Lancer app
adb shell am start -n com.mycompany.my_app/.MainActivity

# Arrêter app
adb shell am force-stop com.mycompany.my_app
```

---

## 📊 MÉTRIQUES DE SUCCÈS

### Temps de Build Cibles

| Action | Cible | Acceptable | Trop lent |
|--------|-------|------------|-----------|
| `flutter pub get` | < 10s | < 30s | > 60s |
| Build incrémental | 2-5 min | 5-10 min | > 15 min |
| Build clean | Éviter | 30-60 min | > 90 min |
| `adb install` | < 15s | < 30s | > 60s |
| Total cycle dev | **3-8 min** | 10-15 min | > 20 min |

---

### Checklist Qualité

- [ ] Build < 10 min
- [ ] Pas d'erreurs linter
- [ ] Tests passent
- [ ] Notifications marchent sur appareil réel
- [ ] Installation sans prompts
- [ ] Pas de secrets en dur
- [ ] Logs robustes (Logger)
- [ ] Gestion erreurs réseau

---

## 🎓 RESSOURCES

### Documentation

- [LESSONS_LEARNED.md](./LESSONS_LEARNED.md) - Leçons détaillées
- [PROMPT_PROCHAINE_SESSION.md](./PROMPT_PROCHAINE_SESSION.md) - Workflow complet
- [Flutter Docs](https://docs.flutter.dev/)
- [Riverpod Docs](https://riverpod.dev/)

### Templates Réutilisables

Tous les templates de ce guide sont copy-paste ready :
- ✅ Structure projet
- ✅ Configuration Gradle
- ✅ Script deploy.ps1
- ✅ Services (HTTP, Notifications, Logger)
- ✅ pubspec.yaml

---

## 🚀 QUICK START (30 MIN)

```bash
# 1. Créer projet
flutter create my_app
cd my_app

# 2. Copier templates
# - Copier structure lib/
# - Copier android/app/build.gradle.kts
# - Copier scripts/deploy.ps1
# - Copier pubspec.yaml

# 3. Install packages
flutter pub get

# 4. Premier build
flutter build apk --release

# 5. Tester
adb install -r build/app/outputs/flutter-apk/app-release.apk

# 6. Lancer
adb shell am start -n com.mycompany.my_app/.MainActivity
```

**Temps total** : 30 minutes  
**vs sans ce guide** : 4-6 heures

---

## 🎯 CONCLUSION

Ce guide te permet de **démarrer un projet Flutter en 30 min** et de **le finir en 1-2 jours** au lieu de 1-2 semaines.

**Clés du succès** :
1. ⚡ Copier templates éprouvés
2. ⚡ Éviter `flutter clean`
3. ⚡ Automatiser avec scripts
4. ⚡ Utiliser packages maintenus
5. ⚡ Logger robuste dès le début
6. ⚡ Tester sur appareil réel tôt

**ROI** : **80-90% de temps économisé** sur chaque projet ! 🚀

---

**Document créé le** : 17 Octobre 2025  
**Basé sur** : Projet XiaoXin002  
**Statut** : ✅ Prêt pour production

---

**💡 Remember : La rapidité vient de l'expérience, pas de la précipitation !**


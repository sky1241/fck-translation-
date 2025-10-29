# 🚀 PROMPT SESSION DEMAIN - 22 Octobre 2025

**Status:** ⚠️ BUGS IDENTIFIÉS - Code modifié mais PAS rebuildé correctement  
**Action requise:** REBUILD FINAL avec TOUTES les corrections

---

## 🔴 BUGS CRITIQUES DÉCOUVERTS AUJOURD'HUI

### Bug 1 : Messages en mode hors ligne NE PARTENT JAMAIS
**Symptôme :** 
- Active mode avion
- Envoie message
- Désactive mode avion
- ❌ Message jamais reçu par l'autre device

**Cause identifiée :**
Le système de queue a un défaut de logique. Dans `_sendOrQueue()`, j'ai essayé de :
1. Mettre en queue
2. Essayer d'envoyer
3. Si succès → retirer de la queue

MAIS le problème est que `_rt!.send()` retourne TOUJOURS `true` même quand la connexion WebSocket n'est pas vraiment établie.

**Solution à implémenter :**
```dart
// Dans RealtimeService.send()
Future<bool> send(Map<String, Object?> payload) async {
  if (_channel == null || !_isConnected) {
    print('[relay][out] ❌ Not connected');
    return false;
  }
  
  try {
    final String text = jsonEncode(payload);
    _channel!.sink.add(text);
    print('[relay][out] ✅ $text');
    return true;
  } catch (e) {
    print('[relay][out] ❌ Send error: $e');
    return false;
  }
}
```

**MAIS ATTENTION** : Le flag `_isConnected` se met à `true` trop tôt (après 2 secondes de timeout). Il faut le mettre à `true` UNIQUEMENT quand on reçoit la PREMIÈRE donnée du serveur.

---

### Bug 2 : Photos restent GRISÉES dans PhotoViewer
**Symptôme :**
- Ouvre la galerie ❤️ → Photos visibles en miniature ✅
- Clique sur une photo pour l'agrandir → GRIS ❌

**Cause identifiée :**
Le `Base64ImageWidget` que j'ai créé existe dans le code, MAIS :
1. Il n'est peut-être pas buildé dans l'APK actuel
2. OU il y a une erreur au décodage base64

**Solution à vérifier :**
```dart
// Dans base64_image_widget.dart
if (imageSource.startsWith('data:image')) {
  final base64Data = imageSource.split(',').last;
  final Uint8List bytes = base64Decode(base64Data);
  
  return Image.memory(
    bytes,
    fit: fit,
    errorBuilder: (context, error, stackTrace) {
      print('[Base64ImageWidget] ❌ Error: $error');
      return Container(color: Colors.red); // Pour voir l'erreur
    },
  );
}
```

**À TESTER après rebuild :**
- Regarder les logs `[PhotoViewer] Loading photo`
- Regarder les logs `[Base64ImageWidget]`

---

### Bug 3 : Connexion WebSocket instable
**Symptôme :**
Les logs montrent des cycles de connexion/déconnexion :
```
✅ Connected (timeout)
🔴 Disconnected
🔄 Reconnecting...
✅ Connected (timeout)
```

**Cause :**
Le serveur `wss://fck-relay-ws.onrender.com` (Render.com gratuit) :
- Se met en veille après 15 min d'inactivité
- Prend 30-60 secondes à se réveiller
- Les connexions échouent pendant le réveil

**Solutions possibles :**
1. Garder une app ouverte en permanence
2. Ping périodique toutes les 10 minutes
3. OU héberger le serveur ailleurs (non-gratuit)

---

## ✅ MODIFICATIONS DÉJÀ FAITES DANS LE CODE

Ces modifications sont DANS LE CODE mais PAS dans les APK actuellement installés :

### 1. MessageQueue créée (`lib/core/network/message_queue.dart`)
- Stockage persistant (SharedPreferences)
- Méthode `enqueue()` qui retourne l'ID
- Méthode `remove(id)` pour supprimer par ID
- Retry counter avec limite (max 5)

### 2. RealtimeService modifié (`lib/core/network/realtime_service.dart`)
- Stream `connectionStatus` pour surveiller la connexion
- Flag `_isConnected` 
- Méthode `send()` retourne `bool` (succès/échec)
- Logs : ✅ Connected, 🔴 Disconnected, 🔄 Reconnecting

### 3. ChatController modifié (`lib/features/chat/presentation/chat_controller.dart`)
- Import de `message_queue.dart`
- Méthode `_sendOrQueue()` qui met en queue + essaye d'envoyer
- Méthode `_processQueue()` appelée à chaque reconnexion
- Utilise `_sendOrQueue()` au lieu de `_rt!.send()` direct

### 4. Base64ImageWidget créé (`lib/features/chat/presentation/widgets/base64_image_widget.dart`)
- Détecte si `data:image` → décode base64
- Sinon → affiche URL normale
- Gestion d'erreurs

### 5. Widgets modifiés pour utiliser Base64ImageWidget
- `photo_viewer.dart` - Visualiseur plein écran
- `photo_grid_item.dart` - Grille galerie
- `attachment_bubble.dart` - Photos dans le chat

### 6. Photos reçues en base64 acceptées (`chat_controller.dart`)
```dart
// Ligne 101-108
final String? base64Data = msg['base64'] as String?;
if (id == null || mime == null || k == null) return;
if (url == null && base64Data == null) return;
final String effectiveUrl = url ?? base64Data!;
```

---

## 🚨 PROBLÈMES RESTANTS À CORRIGER

### Problème A : `_isConnected` se met à `true` trop tôt

**Code actuel** (ligne 69-74 realtime_service.dart) :
```dart
await Future.delayed(const Duration(seconds: 2));
if (_channel != null && !_isConnected) {
  _isConnected = true;
  _connectionCtrl.add(true);
  print('[relay] ✅ Connected (timeout)');
}
```

**Problème :** Après 2 secondes, on dit "connecté" MÊME si le serveur dort.

**Vraie solution :**
```dart
// NE PAS mettre _isConnected à true après timeout
// Le mettre UNIQUEMENT quand on reçoit des données (ligne 47-51)
// OU après un ping/pong avec le serveur

// Supprimer les lignes 69-74 complètement
```

---

### Problème B : PhotoViewer peut crasher silencieusement

Le code a des logs mais peut crasher AVANT d'arriver à `_buildImage()`.

**À ajouter dans PhotoViewer.build() :**
```dart
try {
  // ... code existant ...
} catch (e, stack) {
  print('[PhotoViewer] CRASH in build(): $e');
  print(stack);
  return Scaffold(
    appBar: AppBar(title: Text('Erreur')),
    body: Center(child: Text('Erreur: $e')),
  );
}
```

---

## 🎯 PLAN D'ACTION POUR DEMAIN

### Étape 1 : Corriger le code (5 min)

**A. Supprimer le timeout dans RealtimeService**
```dart
// Dans connect(), SUPPRIMER ces lignes :
// await Future.delayed(const Duration(seconds: 2));
// if (_channel != null && !_isConnected) {
//   _isConnected = true;
//   _connectionCtrl.add(true);
// }
```

**B. Ajouter un vrai système de ping/pong**
```dart
// Envoyer un ping toutes les 5 secondes
// Si pas de réponse après 10 sec → _isConnected = false
```

**C. Wrapper PhotoViewer.build() dans try/catch**

---

### Étape 2 : Builder les 2 versions (~60 min)

```powershell
cd "C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-"

# Clé API
$env:OPENAI_API_KEY = "YOUR_OPENAI_API_KEY_HERE"

# Build 001
flutter build apk --release `
  --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY `
  --dart-define=CHAT_DEFAULT_DIRECTION=fr2zh `
  --dart-define=APP_VERSION=001 `
  --dart-define=RELAY_ROOM=demo123

Copy-Item "build\app\outputs\flutter-apk\app-release.apk" "..\XiaoXin-001-TOI-FRANCAIS.apk" -Force

# Build 002
flutter build apk --release `
  --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY `
  --dart-define=CHAT_DEFAULT_DIRECTION=zh2fr `
  --dart-define=APP_VERSION=002 `
  --dart-define=RELAY_ROOM=demo123

Copy-Item "build\app\outputs\flutter-apk\app-release.apk" "..\XiaoXin-002-ELLE-CHINOIS.apk" -Force
```

---

### Étape 3 : Installer (5 min)

```powershell
cd ..

# Émulateur
adb -s emulator-5554 uninstall com.xiaoxin.xiaoxin002
adb -s emulator-5554 install XiaoXin-001-TOI-FRANCAIS.apk
adb -s emulator-5554 shell am start -n com.xiaoxin.xiaoxin002/.MainActivity

# Téléphone
adb -s FMMFSOOBXO8T5D75 uninstall com.xiaoxin.xiaoxin002
adb -s FMMFSOOBXO8T5D75 install -r -d XiaoXin-002-ELLE-CHINOIS.apk
adb -s FMMFSOOBXO8T5D75 shell am start -n com.xiaoxin.xiaoxin002/.MainActivity
```

---

### Étape 4 : Tester avec logs (10 min)

**Test photos :**
```powershell
adb -s emulator-5554 logcat -c
# Clique sur ❤️, puis sur une photo
adb -s emulator-5554 logcat -d | Select-String "PhotoViewer|Base64"
```

**Test queue :**
```powershell
adb -s FMMFSOOBXO8T5D75 logcat -c
# Active mode avion, envoie message, désactive mode avion
adb -s FMMFSOOBXO8T5D75 logcat -d | Select-String "MessageQueue|sendOrQueue"
```

---

## 📊 RÉSUMÉ DES DÉCOUVERTES D'AUJOURD'HUI

### ✅ Ce qui fonctionne
- Communication FR↔ZH entre les 2 apps (quand connectées)
- Galerie photo affiche les miniatures
- Permissions demandées au démarrage
- Package name changé : `com.xiaoxin.xiaoxin002`
- App name changé : `XiaoXin002`
- RELAY_ROOM : `demo123` (partagé)

### ❌ Ce qui NE fonctionne PAS
- Photos grisées en plein écran (visualiseur)
- Messages hors ligne jamais envoyés à la reconnexion
- Connexion WebSocket instable (cycles connect/disconnect)
- Pas de son sur notifications téléphone (problème Android settings)

### 🔧 Modifications faites (DANS LE CODE, pas buildées)
- MessageQueue système créé
- RealtimeService avec détection connexion
- Base64ImageWidget pour décoder photos
- PhotoViewer modifié pour utiliser Base64ImageWidget
- ChatController avec `_sendOrQueue()` et `_processQueue()`

### 🐛 Bugs dans les modifications
- `_isConnected` se met à `true` après timeout (pas fiable)
- Queue se vide même si envoi échoue
- Pas de vérification réelle de connexion serveur

---

## 💡 SOLUTION RECOMMANDÉE POUR DEMAIN

### Option A : Corriger le système WebSocket actuel (COMPLIQUÉ)
- Ajouter ping/pong
- Améliorer détection connexion
- ~2h de code + debug

### Option B : Simplifier - Accepter les pertes (RAPIDE)
- Supprimer le système de queue
- Dire clairement à l'utilisateur : "Gardez les 2 apps ouvertes"
- Ajouter un indicateur visuel de connexion (🟢/🔴)
- ~30 min

### Option C : Utiliser Firebase Cloud Messaging (PROFESSIONNEL)
- Plus de problème de serveur endormi
- Messages garantis
- Notifications push même app fermée
- ~2-3h de setup

---

## 📝 FICHIERS MODIFIÉS AUJOURD'HUI

```
fck-translation-/lib/core/network/message_queue.dart (CRÉÉ)
fck-translation-/lib/core/network/realtime_service.dart (MODIFIÉ)
fck-translation-/lib/features/chat/presentation/chat_controller.dart (MODIFIÉ)
fck-translation-/lib/features/chat/presentation/widgets/base64_image_widget.dart (CRÉÉ)
fck-translation-/lib/features/chat/presentation/widgets/photo_viewer.dart (MODIFIÉ)
fck-translation-/lib/features/chat/presentation/widgets/photo_grid_item.dart (MODIFIÉ)
fck-translation-/lib/features/chat/presentation/widgets/attachment_bubble.dart (MODIFIÉ)
fck-translation-/android/app/build.gradle.kts (MODIFIÉ - package name)
fck-translation-/android/app/src/main/AndroidManifest.xml (MODIFIÉ - app name)
fck-translation-/android/app/src/main/kotlin/com/xiaoxin/xiaoxin002/MainActivity.kt (CRÉÉ)
```

---

## ⚠️ IMPORTANT

**Les APK actuels (XiaoXin-001/002) datent de 17h32 et 18h19.**

**Les dernières modifications du code ont été faites APRÈS.**

**Il faut rebuilder pour avoir un APK avec TOUTES les corrections.**

**Temps estimé rebuild complet : 60 minutes (30 min × 2 builds)**

---

## 🎯 RECOMMANDATION

Demain, AVANT de rebuilder, décide d'abord :
1. Veux-tu un système de queue complexe mais fiable ? → 2-3h de travail
2. OU veux-tu une solution simple qui marche ? → 30 min

**Ma recommandation perso :** Option B (simple) car l'app est pour usage privé (2 personnes). Un indicateur de connexion suffit.

---

**Créé le :** 21 Octobre 2025 - 21h00
**Priorité :** 🔴 CRITIQUE
**Prochaine action :** Décider de la stratégie (A, B ou C) puis rebuilder


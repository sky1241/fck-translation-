# PROMPT POUR PROCHAINE SESSION - 17 Octobre 2025

## 🎯 Objectifs de la Prochaine Session

### 1. **Notification Permanente (Badge Alternatif)**
Implémenter une notification permanente dans la barre de notifications Android qui affiche le compteur de messages non lus (comme WhatsApp/Telegram).

**Pourquoi ?**
- Les badges sur icône ne fonctionnent PAS sur MIUI du téléphone (testé, result=false)
- `flutter_app_badger` est obsolète et ne marche pas
- `ShortcutBadger` natif retourne false sur ce launcher MIUI
- **Solution** : Notification permanente = fonctionne sur 100% des Android

**À faire :**
- Créer une notification ongoing avec compteur : "3 messages non lus"
- La notification reste visible même quand l'app est fermée
- S'efface automatiquement quand on ouvre le chat
- Fonctionne avec le système existant dans `notification_service_mobile.dart`

### 2. **Mode Silencieux**
Ajouter un bouton/switch pour activer/désactiver le son des notifications.

**Fonctionnalités :**
- Toggle dans l'AppBar ou dans les paramètres
- Quand activé : notifications sans son ni vibration
- Quand désactivé : son + vibration normaux
- Sauvegarder la préférence dans SharedPreferences

---

## 📁 Structure du Projet

### Chemin Principal
```
C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai\qwen_chat_openai\
```

### Fichiers Importants

**Configuration :**
- `pubspec.yaml` - Dépendances Flutter
- `android/app/build.gradle.kts` - Configuration Android
- `android/app/src/main/AndroidManifest.xml` - Permissions Android
- `android/app/src/main/kotlin/com/example/qwen_chat_openai/MainActivity.kt` - Point d'entrée Android
- `android/app/src/main/kotlin/com/example/qwen_chat_openai/BadgePlugin.kt` - Plugin natif badge (créé mais ne marche pas sur MIUI)

**Code Source Principal :**
- `lib/main.dart` - Point d'entrée app
- `lib/app.dart` - Configuration MaterialApp
- `lib/core/env/app_env.dart` - Variables d'environnement (clés API)
- `lib/core/network/notification_service.dart` - Service notifications (export conditionnel)
- `lib/core/network/notification_service_mobile.dart` - **À MODIFIER** pour notification permanente
- `lib/core/network/badge_service.dart` - Service badge (actuellement ne marche pas)
- `lib/core/network/realtime_service.dart` - WebSocket relay
- `lib/features/chat/presentation/chat_page.dart` - Page principale chat
- `lib/features/chat/presentation/chat_controller.dart` - Logique chat (Riverpod)
- `lib/features/chat/data/translation_service.dart` - Service traduction OpenAI

---

## 🔧 Workflow de Build et Déploiement

### 1. **Build Normal (Incrémental - Rapide 2-5 min)**
```bash
cd "C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai\qwen_chat_openai"

flutter build apk --release \
  --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions \
  --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY \
  --dart-define=OPENAI_PROJECT=$env:OPENAI_PROJECT \
  --dart-define=OPENAI_MODEL=gpt-4o-mini \
  --dart-define=RELAY_WS_URL=wss://fck-relay-ws.onrender.com \
  --dart-define=RELAY_ROOM=demo123
```

### 2. **Build Propre (Clean - Long 60-90 min mais nécessaire si bugs)**
```bash
cd "C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai\qwen_chat_openai"

flutter clean
# Attendre ~2 minutes

flutter build apk --release \
  --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions \
  --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY \
  --dart-define=OPENAI_PROJECT=$env:OPENAI_PROJECT \
  --dart-define=OPENAI_MODEL=gpt-4o-mini \
  --dart-define=RELAY_WS_URL=wss://fck-relay-ws.onrender.com \
  --dart-define=RELAY_ROOM=demo123
```

**⚠️ IMPORTANT** : Faire `flutter clean` UNIQUEMENT si :
- Les modifications de code ne sont pas compilées
- Il y a des erreurs bizarres de compilation
- On change de version de dépendance majeure

### 3. **Installation sur Téléphone + Émulateur**
```bash
# Vérifier appareils connectés
adb devices
# Devrait montrer :
# FMMFSOOBXO8T5D75   device  (téléphone)
# emulator-5554      device  (émulateur)

# Si offline, redémarrer ADB
adb kill-server
adb start-server
adb devices

# Installer sur les deux
adb -s FMMFSOOBXO8T5D75 install -r build\app\outputs\flutter-apk\app-release.apk
adb -s emulator-5554 install -r build\app\outputs\flutter-apk\app-release.apk
```

### 4. **Lancer les Apps**
```bash
# Arrêter d'abord (pour charger nouveau code)
adb -s FMMFSOOBXO8T5D75 shell am force-stop com.example.qwen_chat_openai
adb -s emulator-5554 shell am force-stop com.example.qwen_chat_openai

# Lancer
adb -s FMMFSOOBXO8T5D75 shell am start -n com.example.qwen_chat_openai/.MainActivity
adb -s emulator-5554 shell am start -n com.example.qwen_chat_openai/.MainActivity
```

### 5. **Surveiller les Logs (Débogage)**
```bash
# Nettoyer et surveiller
adb -s FMMFSOOBXO8T5D75 logcat -c
adb -s FMMFSOOBXO8T5D75 logcat | Select-String -Pattern "flutter|qwen|notification|Badge|relay|error"

# Chercher dans l'historique
adb -s FMMFSOOBXO8T5D75 logcat -d | Select-String -Pattern "BadgeService|relay.*in" | Select-Object -Last 30
```

---

## 📱 Appareils

### Téléphone
- **ID ADB** : `FMMFSOOBXO8T5D75`
- **Marque** : Xiaomi
- **Launcher** : MIUI (`com.miui.home`)
- **Android** : Probablement Android 11-13
- **Problème badges** : ShortcutBadger retourne false (launcher incompatible)

### Émulateur
- **ID ADB** : `emulator-5554`
- **Nom** : Chat API30lite (lancé depuis Android Studio)
- **Android** : API Level 30 (Android 11)
- **Note** : Plante parfois (System UI not responding) → redémarrer l'émulateur dans Android Studio

---

## 🔑 Variables d'Environnement (Clés API)

Les clés sont dans les variables d'environnement Windows :

```powershell
$env:OPENAI_API_KEY     # Clé API OpenAI (commence par sk-proj-...)
$env:OPENAI_PROJECT     # ID projet OpenAI (commence par proj_...)
```

**Vérifier :**
```powershell
echo $env:OPENAI_API_KEY
echo $env:OPENAI_PROJECT
```

---

## 🌐 Serveurs (Configurés et Fonctionnels)

### Relay WebSocket
- **URL** : `wss://fck-relay-ws.onrender.com`
- **Room** : `demo123`
- **Statut** : ✅ Fonctionnel
- **Fonction** : Communication temps réel entre téléphone et émulateur

### OpenAI Proxy
- **URL** : Utilise directement `https://api.openai.com/v1/chat/completions`
- **Modèle** : `gpt-4o-mini`
- **Statut** : ✅ Fonctionnel

---

## ✅ Ce qui Fonctionne Actuellement

| Fonctionnalité | Status | Note |
|---------------|--------|------|
| 📱 Build APK | ✅ OK | ~5 min (incrémental), ~60 min (clean) |
| 🔌 Installation téléphone/émulateur | ✅ OK | ~10 secondes chacun |
| 💬 Chat FR↔ZH | ✅ OK | Traduction fonctionne |
| 🌐 WebSocket relay | ✅ OK | Messages synchronisés |
| 📖 Prompt traduction LITTÉRAL | ✅ OK | Ne modifie plus les messages |
| 🔐 Clés API OpenAI | ✅ OK | Compilées dans l'APK |
| 📂 Stockage local messages | ✅ OK | SharedPreferences |

## ❌ Ce qui NE Fonctionne PAS

| Problème | Status | Raison |
|---------|--------|--------|
| 🔴 Badge sur icône | ❌ NON | MIUI launcher incompatible avec ShortcutBadger |
| 🔔 Notifications push | ❌ NON | Icône notification plante (désactivé pour l'instant) |

---

## 🎯 TÂCHES POUR LA PROCHAINE SESSION

### Tâche 1 : Notification Permanente (Priorité 1)

**Fichier à modifier** : `lib/core/network/notification_service_mobile.dart`

**Code actuel (ligne 21-26)** :
```dart
Future<void> showIncomingMessage({required String title, required String body}) async {
  // Just increment badge - SKIP notifications completely as they crash
  await BadgeService.increment();
  // Notifications are disabled due to plugin incompatibility
  // Badge will work on Samsung, Xiaomi, Huawei launchers
}
```

**À implémenter** :
```dart
Future<void> showIncomingMessage({required String title, required String body}) async {
  await BadgeService.increment();
  final int count = BadgeService.currentCount;
  
  try {
    final String summaryTitle = count == 1 ? '1 message non lu' : '$count messages non lus';
    final AndroidNotificationDetails summaryAndroid = AndroidNotificationDetails(
      'unread_summary',
      'Messages non lus',
      channelDescription: 'Compteur de messages non lus',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true, // PERMANENTE
      autoCancel: false,
      number: count,
      showWhen: false,
      icon: '@mipmap/ic_launcher', // Utiliser icône app
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );
    final NotificationDetails summaryDetails = NotificationDetails(android: summaryAndroid);
    await _fln.show(999999, summaryTitle, 'Ouvrez XiaoXin002', summaryDetails);
  } catch (e) {
    print('[NotificationService] Error showing summary: $e');
  }
}

Future<void> clearSummaryNotification() async {
  try {
    await _fln.cancel(999999);
  } catch (_) {}
}
```

**Appeler `clearSummaryNotification()` dans** : `lib/features/chat/presentation/chat_page.dart` ligne 37-42

---

### Tâche 2 : Mode Silencieux

**Fichiers à créer/modifier :**

**A. Ajouter état silencieux dans `chat_controller.dart`** :
```dart
bool _silentMode = false;
bool get silentMode => _silentMode;

void toggleSilentMode() {
  _silentMode = !_silentMode;
  // Sauvegarder dans SharedPreferences
  ref.notifyListeners();
}
```

**B. Modifier `notification_service_mobile.dart`** :
```dart
Future<void> showIncomingMessage({
  required String title, 
  required String body,
  bool silent = false, // Nouveau paramètre
}) async {
  // ...
  final AndroidNotificationDetails android = AndroidNotificationDetails(
    'unread_summary',
    'Messages non lus',
    // ...
    playSound: !silent,
    enableVibration: !silent,
    // ...
  );
}
```

**C. Ajouter bouton dans `chat_page.dart` AppBar** :
```dart
actions: <Widget>[
  IconButton(
    tooltip: _silentMode ? 'Mode normal' : 'Mode silencieux',
    onPressed: controller.toggleSilentMode,
    icon: Icon(_silentMode ? Icons.notifications_off : Icons.notifications),
  ),
  IconButton(
    tooltip: 'Swap',
    onPressed: controller.swapDirection,
    icon: const Icon(Icons.swap_horiz),
  ),
],
```

---

## 🔧 Commandes Essentielles

### Workflow Standard
```powershell
# 1. Se placer dans le projet
cd "C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai\qwen_chat_openai"

# 2. Build (SANS flutter clean si possible pour gagner du temps)
flutter build apk --release --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY --dart-define=OPENAI_PROJECT=$env:OPENAI_PROJECT --dart-define=OPENAI_MODEL=gpt-4o-mini --dart-define=RELAY_WS_URL=wss://fck-relay-ws.onrender.com --dart-define=RELAY_ROOM=demo123

# 3. Vérifier appareils
adb devices

# 4. Installer sur les deux
adb -s FMMFSOOBXO8T5D75 install -r build\app\outputs\flutter-apk\app-release.apk
adb -s emulator-5554 install -r build\app\outputs\flutter-apk\app-release.apk

# 5. Lancer (forcer arrêt d'abord pour charger nouveau code)
adb -s FMMFSOOBXO8T5D75 shell am force-stop com.example.qwen_chat_openai
adb -s emulator-5554 shell am force-stop com.example.qwen_chat_openai
adb -s FMMFSOOBXO8T5D75 shell am start -n com.example.qwen_chat_openai/.MainActivity
adb -s emulator-5554 shell am start -n com.example.qwen_chat_openai/.MainActivity

# 6. Surveiller logs (optionnel)
adb -s FMMFSOOBXO8T5D75 logcat -c
adb -s FMMFSOOBXO8T5D75 logcat | Select-String -Pattern "flutter|notification|qwen"
```

### Quand Faire `flutter clean` ?
**❌ Ne PAS faire par défaut** (perd 60-90 minutes)

**✅ Faire UNIQUEMENT si :**
- Les modifications de code ne sont pas dans l'APK (vérifier via logs)
- Erreurs bizarres de compilation Gradle/Kotlin
- Changement de version majeure de package

---

## 📊 État Actuel du Code

### Problèmes Connus

**1. Badges sur icône**
- `BadgePlugin.kt` créé mais `ShortcutBadger.applyCount()` retourne `false` sur MIUI
- Logs montrent : `[BadgeService] Badge set to 4, result: false`
- **Solution** : Utiliser notification permanente à la place

**2. Notifications plantent**
- Icône `ic_stat_notification.xml` ne se charge pas correctement
- Utilise `@mipmap/ic_launcher` comme workaround
- Notifications individuelles désactivées pour éviter crashes

**3. Prompt de traduction**
- **Modifié le 17/10** pour être LITTÉRAL
- Plus d'ajout de mots (avant: "uwu j'ai réussi" → "mon trésor j'ai réussi à finir ce trajet")
- Maintenant: traduction exacte sans modification

### Packages Utilisés

```yaml
dependencies:
  flutter_riverpod: ^2.6.1       # State management
  http: ^1.2.2                   # API calls
  shared_preferences: ^2.4.14    # Stockage local
  freezed_annotation: ^2.4.4     # Modèles immutables
  json_annotation: ^4.9.0        # Sérialisation JSON
  intl: ^0.20.2                  # Dates/heures
  flutter_lints: ^6.0.0          # Linter
  web_socket_channel: ^3.0.3     # WebSocket relay
  flutter_local_notifications: ^17.2.4  # Notifications Android
  image_picker: ^1.1.2           # Pièces jointes (images)
  path_provider: ^2.1.4          # Chemins fichiers
  http_parser: ^4.0.2            # Parsing HTTP
  flutter_svg: ^2.0.10+1         # Logo SVG
```

**Package RETIRÉ** :
- `flutter_app_badger: ^1.5.0` - Obsolète, ne marchait pas

---

## 🧪 Tests

### Test Traduction
```
1. Sur émulateur : Taper "Bonjour mon amour"
2. Vérifier traduction : "你好我的爱" (littérale)
3. Envoyer depuis téléphone : "uwu j'ai réussi"
4. Vérifier traduction : "uwu 我成功了" (PAS "mon trésor...")
```

### Test WebSocket Relay
```
1. Message depuis émulateur → Arrive sur téléphone
2. Message depuis téléphone → Arrive sur émulateur
3. Logs montrent : [relay][in] {"type":"text",...}
```

### Test Notifications (À implémenter)
```
1. Recevoir message pendant que l'app est minimisée
2. Vérifier notification permanente : "1 message non lu"
3. Recevoir 2ème message → "2 messages non lus"
4. Ouvrir app → Notification disparaît
```

---

## 💾 Logs et Débogage

### Logs Importants à Surveiller

**Message WebSocket reçu** :
```
[relay][in] {"type":"text","text":"...","source_lang":"fr","target_lang":"zh",...}
```

**Badge appelé** :
```
[BadgeService] Incrementing badge to X via native plugin
[BadgeService] Badge set to X, result: true/false
```

**Notification** :
```
[NotificationService] Showing summary notification
```

**Erreurs communes** :
```
MissingPluginException         → Le plugin n'est pas enregistré
NullPointerException          → Icône notification manquante
PlatformException(error...)   → Problème Android natif
```

---

## 📝 Historique des Modifications - 17 Octobre 2025

### Session Actuelle (4+ heures)

**1. Analyse complète du projet**
- ✅ Confirmé : Aucun cœur (❤️) pour sélection de ton dans l'UI
- ✅ Serveurs OK (relay WebSocket + OpenAI)
- ❌ Badge pas configuré

**2. Tentatives de configuration badge (multiples essais)**
- Essai 1 : `flutter_app_badger` → Obsolète, incompatible Gradle
- Essai 2 : Fix manuel du package dans cache Pub → Compile mais "not supported"
- Essai 3 : Icône notification custom → NullPointerException
- Essai 4 : Icône `@mipmap/ic_launcher` → Marche mais badge false
- Essai 5 : Plugin natif Kotlin custom (`BadgePlugin.kt`) → `ShortcutBadger.applyCount()` retourne false

**Résultat** : Les badges sur icône ne fonctionnent PAS sur ce MIUI launcher.

**3. Modification prompt traduction**
- Changé de "adaptation culturelle" → "traduction LITTÉRALE"
- Ajout règle : "NO ADDITIONS - translate EXACTLY what is written"
- Exemples ajoutés : "uwu j'ai réussi" → "uwu 我成功了"

**4. Optimisation temps de build**
- Build incrémental (sans clean) : 2-7 minutes ✅
- Build propre (avec clean) : 60-90 minutes ❌
- Gain de temps : 85 minutes économisées !

---

## 🚀 PROMPT POUR LA PROCHAINE SESSION

```
Salut ! J'ai une app Flutter de chat FR↔ZH (XiaoXin002) déjà fonctionnelle.

CONTEXTE :
- Projet dans : C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai\qwen_chat_openai\
- Téléphone Xiaomi (FMMFSOOBXO8T5D75) + Émulateur (emulator-5554)
- Les badges sur icône NE MARCHENT PAS sur mon launcher MIUI (ShortcutBadger retourne false)
- Build APK : flutter build apk --release avec clés API dans $env:OPENAI_API_KEY et $env:OPENAI_PROJECT
- Installation : adb -s [device] install -r build\app\outputs\flutter-apk\app-release.apk
- NE PAS faire flutter clean sauf si nécessaire (perd 90 min !)

OBJECTIFS :
1. IMPLÉMENTER une notification permanente dans la barre de notification Android (comme WhatsApp/Telegram)
   - Affiche "X messages non lus" en permanence
   - Disparaît quand on ouvre le chat
   - Fichiers : lib/core/network/notification_service_mobile.dart + lib/features/chat/presentation/chat_page.dart
   - ID notification : 999999

2. AJOUTER un mode silencieux
   - Bouton/switch dans l'AppBar
   - Désactive son + vibration des notifications
   - Sauvegarder dans SharedPreferences
   - Fichiers : lib/features/chat/presentation/chat_controller.dart + chat_page.dart + notification_service_mobile.dart

WORKFLOW :
1. Modifier le code
2. Build incrémental (SANS flutter clean) : flutter build apk --release + toutes les --dart-define
3. Installer sur FMMFSOOBXO8T5D75 ET emulator-5554
4. Force-stop puis start : com.example.qwen_chat_openai/.MainActivity
5. Tester et surveiller logs : adb logcat | Select-String "flutter|notification"

CONTRAINTES :
- Build incrémental (2-5 min) >> Build clean (60-90 min) → Éviter clean !
- Vérifier via logs que le code est bien compilé
- Tester sur les DEUX appareils
- Package com.example.qwen_chat_openai

Aide-moi à implémenter ces 2 fonctionnalités en optimisant le temps de build. Merci !
```

---

## 📚 Documentation Créée Aujourd'hui

- `docs/BADGE_CONFIGURATION.md` - Guide badge (non fonctionnel finalement)
- `docs/VERIFICATION_16_OCT_2025.md` - Rapport vérification
- `docs/PROMPT_PROCHAINE_SESSION.md` - Ce document
- `rebuild_with_badge.ps1` - Script rebuild (non utilisé)
- `quick_build_badge.ps1` - Script build rapide (non utilisé)
- `android/app/src/main/kotlin/.../BadgePlugin.kt` - Plugin natif (ne marche pas sur MIUI)

---

## 🎓 Leçons Apprises

1. **Badges Android = Cauchemar**
   - Pas standardisés, dépendent du launcher
   - Même les bibliothèques natives (ShortcutBadger) échouent
   - WhatsApp/Telegram utilisent des notifications permanentes à la place

2. **Flutter Clean = Dernier Recours**
   - Perd énormément de temps (60-90 min vs 2-5 min)
   - N'utiliser que si le code n'est vraiment pas compilé

3. **Mode Release = Pas de logs print()**
   - Les `print()` Dart ne s'affichent pas toujours en release
   - Utiliser `flutter run --release` pour débugger avec logs

4. **ADB = Fragile**
   - Appareils passent souvent "offline"
   - `adb kill-server && adb start-server` pour reset

---

**Date** : 17 Octobre 2025  
**Temps passé** : ~4-5 heures  
**Status** : Badge abandonné, prêt pour notification permanente + mode silencieux


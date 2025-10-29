# 🚀 PROMPT POUR NOUVELLE SESSION - Améliorations UX

**Date** : 17 Octobre 2025  
**Projet** : XiaoXin002 - App Chat FR↔ZH

---

## 📋 CONTEXTE PROJET

**Chemin** : `C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai\qwen_chat_openai\`

**Appareils** :
- Téléphone Xiaomi : `FMMFSOOBXO8T5D75`
- Émulateur Android Studio : `emulator-5554` (Chat API30lite)

**Clés API** (dans variables d'environnement Windows) :
```powershell
$env:OPENAI_API_KEY    # sk-proj-...
$env:OPENAI_PROJECT    # proj_...
```

**État Actuel** : App fonctionne (chat, traduction, WebSocket sync), mais UX à améliorer.

---

## 🎯 OBJECTIFS DE CETTE SESSION

### 1. 🔴 **Point Rouge Notification DANS l'App**
**Problème** : On sait si on a reçu des messages seulement en ouvrant l'app  
**Solution** : Badge rouge sur l'icône interne de l'app (comme un compteur de notifs non lues dans l'AppBar)

**Où** : Afficher un petit badge rouge dans l'AppBar avec le nombre de messages non lus

**Note** : PAS sur l'icône du téléphone (impossible sur MIUI), mais DANS l'interface de l'app

---

### 2. 📜 **Auto-Scroll vers le Dernier Message**
**Problème** : Quand on reçoit un message, il faut scroller manuellement vers le bas  
**Solution** : Scroll automatique vers le message le plus récent

**Comportement attendu** :
- Message envoyé → Scroll auto vers bas
- Message reçu → Scroll auto vers bas
- Ouverture app → Scroll vers bas (déjà fait mais à vérifier)

---

### 3. 🌍 **Détection Automatique de Langue**
**Problème** : Ma copine parle chinois, moi français. On doit manuellement changer la direction.  
**Solution** : Détection automatique de la langue du message tapé

**Comportement** :
- Je tape en **français** → Détecte automatiquement → Traduit en **chinois** pour elle
- Elle tape en **chinois** → Détecte automatiquement → Traduit en **français** pour moi
- Plus besoin du bouton swap (ou le garder pour forcer si détection rate)

**Implémentation** :
- Détecter si le texte contient des caractères chinois (regex: `[\u4e00-\u9fff]`)
- Si chinois détecté → source=zh, target=fr
- Si pas chinois → source=fr, target=zh
- Simple et fiable pour ce cas d'usage (seulement 2 langues)

---

### 4. 💬 **Masquer le Message Original de l'Utilisateur**
**Problème** : Quand j'écris "Bonjour", ça affiche :
- Ma bulle : "Bonjour" (en petit italique)
- Bulle réponse : "你好" (traduction)
→ Ça fait 2 bulles pour 1 message, encombre la conversation

**Solution** : Afficher SEULEMENT la traduction

**Comportement attendu** :
- J'écris "Bonjour" → Affiche juste "你好" (bulle côté destinataire)
- Elle écrit "你好" → Affiche juste "Bonjour" (bulle côté destinataire)
- Supprime la bulle "original" de l'expéditeur

**Logique** :
```
Message envoyé (isMe=true) :
  - NE PAS afficher dans la liste (ou cacher)
  
Message traduit (isMe=false) :
  - Afficher la traduction normalement
```

---

## 📝 TODO LIST (Ordre de Priorité)

### ✅ TODO 1 : Auto-Scroll vers Dernier Message
**Priorité** : 🔥 Haute (QoL essentiel)  
**Difficulté** : ⭐ Facile  
**Temps estimé** : 5 minutes

**Fichier** : `lib/features/chat/presentation/chat_page.dart`

**Modifications** :
```dart
// Dans _ChatPageState, après ref.notifyListeners() dans send() et _receiveRemote()

// Option 1 : Scroll avec animation
WidgetsBinding.instance.addPostFrameCallback((_) {
  if (_listCtrl.hasClients) {
    _listCtrl.animateTo(
      _listCtrl.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
});

// Option 2 : Scroll immédiat (plus rapide)
WidgetsBinding.instance.addPostFrameCallback((_) {
  if (_listCtrl.hasClients) {
    _listCtrl.jumpTo(_listCtrl.position.maxScrollExtent);
  }
});
```

**Emplacements** :
- Ligne ~120 : Après `await send(text)` dans onSend callback (déjà fait, vérifier)
- Dans `chat_controller.dart` : Après `state = [...state, replyMsg]` (ligne ~292 et ~338)

**Test** :
1. Envoyer message → Scroll auto ✅
2. Recevoir message via WebSocket → Scroll auto ✅

---

### ✅ TODO 2 : Détection Automatique de Langue
**Priorité** : 🔥 Haute (Feature clé pour UX couple)  
**Difficulté** : ⭐⭐ Moyenne  
**Temps estimé** : 15 minutes

**Fichier** : `lib/features/chat/presentation/chat_controller.dart`

**Ajout d'une fonction** :
```dart
String _detectLanguage(String text) {
  // Détecte si le texte contient des caractères chinois
  final RegExp chineseRegex = RegExp(r'[\u4e00-\u9fff]');
  if (chineseRegex.hasMatch(text)) {
    return 'zh';
  }
  return 'fr';
}
```

**Modifier la méthode `send()`** (ligne ~234) :
```dart
Future<void> send(String text, {bool broadcast = true}) async {
  if (text.trim().isEmpty) return;
  
  // DÉTECTION AUTOMATIQUE DE LANGUE
  final String detectedLang = _detectLanguage(text);
  
  // Définir automatiquement source et target
  if (detectedLang == 'zh') {
    _sourceLang = 'zh';
    _targetLang = 'fr';
  } else {
    _sourceLang = 'fr';
    _targetLang = 'zh';
  }
  
  // ... reste du code send() inchangé
}
```

**⚠️ OBLIGATOIRE : Retirer le bouton swap dans AppBar**
```dart
// Dans chat_page.dart, ligne ~52-56
// SUPPRIMER ces lignes :
IconButton(
  tooltip: 'Swap',
  onPressed: controller.swapDirection,
  icon: const Icon(Icons.swap_horiz),
),
```

**Test** :
1. Taper "Bonjour" → Détecte français → Traduit en chinois ✅
2. Taper "你好" → Détecte chinois → Traduit en français ✅
3. Vérifier titre AppBar change automatiquement (FR→ZH ou ZH→FR) ✅
4. Vérifier bouton swap a disparu de l'AppBar ✅

---

### ✅ TODO 3 : Masquer Message Original Utilisateur
**Priorité** : ⭐ Moyenne (Simplifie l'UI)  
**Difficulté** : ⭐ Facile  
**Temps estimé** : 10 minutes

**Option A : Ne Pas Créer le Message Utilisateur**

**Fichier** : `lib/features/chat/presentation/chat_controller.dart`

**Modifier `send()`** (ligne ~251-260) :
```dart
// AVANT (ligne ~251-260)
final ChatMessage userMsg = ChatMessage(
  id: DateTime.now().microsecondsSinceEpoch.toString(),
  originalText: text,
  translatedText: '',
  isMe: true,
  time: DateTime.now().toUtc(),
);
state = <ChatMessage>[...state, userMsg];
await saveMessages();

// APRÈS (SUPPRIMER ces lignes)
// Ne plus créer userMsg, créer directement le message traduit après l'API call
```

**Garder seulement** :
```dart
// Appelle la traduction SANS créer de message avant
final TranslationResult res = await _repo.translate(...);

// Crée SEULEMENT le message traduit
final ChatMessage replyMsg = ChatMessage(
  id: DateTime.now().microsecondsSinceEpoch.toString(),
  originalText: text, // On garde l'original pour référence mais pas affiché
  translatedText: res.translation,
  isMe: false, // IMPORTANT : false pour afficher côté destinataire
  time: DateTime.now().toUtc(),
  pinyin: res.pinyin,
  notes: res.notes,
);
state = <ChatMessage>[...state, replyMsg];
```

**Option B : Filtrer dans l'Affichage**
```dart
// Dans chat_page.dart, ligne ~81
itemBuilder: (BuildContext context, int index) {
  final m = messages[index];
  // SKIP les messages isMe (ceux qu'on envoie)
  if (m.isMe && m.translatedText.isEmpty) {
    return const SizedBox.shrink(); // Message invisible
  }
  // ...
```

**Test** :
1. J'envoie "Bonjour" → Affiche SEULEMENT "你好" (1 bulle) ✅
2. Elle envoie "你好" → Affiche SEULEMENT "Bonjour" (1 bulle) ✅

---

### ✅ TODO 4 : Point Rouge Notification DANS l'App
**Priorité** : ⭐⭐ Moyenne-Basse (Nice to have)  
**Difficulté** : ⭐⭐ Moyenne  
**Temps estimé** : 20 minutes

**Concept** : Badge rouge sur l'icône dans l'AppBar (pas sur icône téléphone)

**Fichier** : `lib/features/chat/presentation/chat_page.dart`

**Modifier AppBar** (ligne ~49-58) :
```dart
appBar: AppBar(
  title: Text(title),
  actions: <Widget>[
    // Badge avec compteur
    Stack(
      children: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: () {}, // Optionnel : ouvrir liste notifs
          icon: const Icon(Icons.notifications),
        ),
        if (BadgeService.currentCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                '${BadgeService.currentCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    ),
    IconButton(
      tooltip: 'Swap',
      onPressed: controller.swapDirection,
      icon: const Icon(Icons.swap_horiz),
    ),
  ],
),
```

**Ajout : Écouter le scroll pour auto-clear** :
```dart
// Dans initState() ou build()
_listCtrl.addListener(() {
  // Quand scroll atteint le bas (message lu) → clear badge
  if (_listCtrl.hasClients && 
      _listCtrl.position.pixels >= _listCtrl.position.maxScrollExtent - 100) {
    BadgeService.clear();
  }
});
```

**Rendre réactif** :
- Utiliser `ref.watch(badgeCountProvider)` ou forcer rebuild après increment/clear
- Ou ValueNotifier pour BadgeService.currentCount

**Test** :
1. Recevoir message → Point rouge avec "1" apparaît dans AppBar ✅
2. Recevoir 2ème → Point rouge avec "2" ✅
3. Scroll vers bas → Point rouge disparaît AUTO ✅
4. Ouvrir app → Scroll bas → Point rouge disparaît ✅

---

## 🔧 WORKFLOW OPTIMISÉ

### Build et Deploy (2-5 minutes total)

```powershell
# 1. Se placer dans le projet
cd "C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai\qwen_chat_openai"

# 2. Build SANS flutter clean (sauf si code pas compilé)
flutter build apk --release --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY --dart-define=OPENAI_PROJECT=$env:OPENAI_PROJECT --dart-define=OPENAI_MODEL=gpt-4o-mini --dart-define=RELAY_WS_URL=wss://fck-relay-ws.onrender.com --dart-define=RELAY_ROOM=demo123

# 3. Vérifier appareils
adb devices
# Si offline : adb kill-server && adb start-server && adb devices

# 4. Installer sur les deux
adb -s FMMFSOOBXO8T5D75 install -r build\app\outputs\flutter-apk\app-release.apk
adb -s emulator-5554 install -r build\app\outputs\flutter-apk\app-release.apk

# 5. Force-stop (OBLIGATOIRE pour charger nouveau code!)
adb -s FMMFSOOBXO8T5D75 shell am force-stop com.example.qwen_chat_openai
adb -s emulator-5554 shell am force-stop com.example.qwen_chat_openai

# 6. Lancer
adb -s FMMFSOOBXO8T5D75 shell am start -n com.example.qwen_chat_openai/.MainActivity
adb -s emulator-5554 shell am start -n com.example.qwen_chat_openai/.MainActivity

# 7. Logs (optionnel)
adb -s FMMFSOOBXO8T5D75 logcat -c
adb -s FMMFSOOBXO8T5D75 logcat | Select-String -Pattern "flutter|qwen|relay"

# 8. ⚠️ FINAL : Copier APK dans dist/ pour téléchargement (IMPORTANT!)
# TESTER L'APP AVANT DE COPIER (vérifier toutes les modifs fonctionnent)
copy build\app\outputs\flutter-apk\app-release.apk dist\qwen-chat-openai-release-$(Get-Date -Format "yyyyMMdd").apk
# Ou juste :
copy build\app\outputs\flutter-apk\app-release.apk dist\qwen-chat-openai-release.apk
# → Ce fichier sera téléchargé par la copine via lien
```

**⚠️ NE PAS faire `flutter clean` sauf si absolument nécessaire (perd 85 minutes)**

**⚠️ VÉRIFIER L'APK FINAL** :
- Tester TOUTES les fonctionnalités (détection langue, scroll, 1 bulle, point rouge)
- Vérifier que le code est bien à jour (pas l'ancien code qui tourne)
- Seulement APRÈS validation → Copier dans dist/ pour lien copine

---

## 📱 TESTS À EFFECTUER

### Test 1 : Auto-Scroll
```
1. Émulateur : Envoyer "test scroll"
2. Téléphone : Vérifier que la conversation scroll vers le bas automatiquement
3. Téléphone : Envoyer "réponse"
4. Émulateur : Vérifier scroll auto
```

### Test 2 : Détection Auto Langue
```
1. Téléphone : Taper "Bonjour" (français)
   → Devrait traduire en chinois automatiquement
   
2. Téléphone : Taper "你好" (chinois)
   → Devrait traduire en français automatiquement
   
3. Vérifier titre AppBar change : FR→ZH ou ZH→FR
```

### Test 3 : Messages Simplifiés
```
1. Téléphone : Taper "Je t'aime"
   → Devrait afficher SEULEMENT "我爱你" (1 bulle, pas 2)
   
2. Émulateur : Taper "想你"
   → Devrait afficher SEULEMENT "Tu me manques" (1 bulle)
```

### Test 4 : Point Rouge Interne
```
1. Téléphone : App ouverte
2. Émulateur : Envoyer "test badge"
3. Téléphone : Minimiser l'app (HOME)
4. Téléphone : Rouvrir l'app
   → Point rouge "1" visible dans AppBar ✅
5. Scroll vers bas (lire le message)
   → Point rouge disparaît ✅
```

---

## 🎯 PROMPT À COPIER-COLLER

```
Salut ! J'ai une app Flutter de chat FR↔ZH (XiaoXin002) qui fonctionne bien. J'ai besoin d'améliorer l'UX avec 4 modifications.

CONTEXTE :
- Projet : C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai\qwen_chat_openai\
- Téléphone : FMMFSOOBXO8T5D75 (Xiaomi MIUI)
- Émulateur : emulator-5554 (Chat API30lite)
- Clés API dans : $env:OPENAI_API_KEY et $env:OPENAI_PROJECT
- Build : flutter build apk --release avec --dart-define pour les clés
- NE PAS faire flutter clean sauf si code pas compilé (perd 85 min)
- Après install : TOUJOURS faire force-stop puis start, sinon ancien code tourne !

OBJECTIFS (TODO LIST) :

[ ] 1. AUTO-SCROLL vers dernier message (5 min)
    - Quand message envoyé → scroll auto vers bas
    - Quand message reçu (WebSocket) → scroll auto vers bas
    - Fichiers : chat_page.dart (ligne ~120) + chat_controller.dart (après state update)
    - Code : WidgetsBinding.instance.addPostFrameCallback + _listCtrl.animateTo(maxScrollExtent)

[ ] 2. DÉTECTION AUTOMATIQUE DE LANGUE (15 min)
    - Détecte si texte contient chinois (regex [\u4e00-\u9fff])
    - Si chinois → traduit en français
    - Si pas chinois → traduit en chinois
    - ⚠️ SUPPRIMER le bouton swap (flèche 🔄) dans AppBar (plus besoin avec auto-détection)
    - Fichiers : chat_controller.dart (send() ligne ~234) + chat_page.dart (retirer IconButton swap ligne ~52-56)
    - Fonction : String _detectLanguage(String text)

[ ] 3. MASQUER MESSAGE ORIGINAL utilisateur (10 min)
    - Actuellement : J'écris "Bonjour" → affiche ma bulle + bulle traduction (2 bulles)
    - Attendu : J'écris "Bonjour" → affiche SEULEMENT la traduction "你好" (1 bulle)
    - Solution : Ne PAS créer le userMsg (ligne ~251-260 chat_controller.dart)
    - Ou filtrer dans itemBuilder (chat_page.dart ligne ~81)

[ ] 4. POINT ROUGE notification DANS l'app (20 min)
    - Badge rouge dans AppBar avec compteur messages non lus
    - PAS sur icône téléphone (impossible MIUI)
    - Badge DANS l'interface app (comme compteur notifs)
    - ⚠️ DISPARITION AUTO : Quand scroll atteint le bas (message lu) → point rouge disparaît automatiquement
    - Fichier : chat_page.dart AppBar (ligne ~49) + écouter position scroll
    - Widget : Stack avec Positioned badge rouge + nombre
    - Logic : if (_listCtrl.position.pixels >= maxScrollExtent - 100) → BadgeService.clear()

WORKFLOW :
1. Modifier le code
2. flutter build apk --release (avec toutes les --dart-define)
3. adb devices (si offline: adb kill-server && adb start-server)
4. Installer sur FMMFSOOBXO8T5D75 ET emulator-5554
5. Force-stop PUIS start (OBLIGATOIRE : com.example.qwen_chat_openai/.MainActivity)
6. Tester sur les deux appareils
7. ⚠️ IMPORTANT : Copier l'APK final dans dist/ pour lien de téléchargement (copine télécharge via lien)

CONTRAINTES :
- Build incrémental (2-5 min) >> Build clean (60-90 min)
- Toujours force-stop après install sinon ancien code !
- Supprimer bouton swap (flèche) car détection auto suffit
- Point rouge disparaît AUTO quand scroll en bas (message lu)
- ⚠️ À LA FIN : Copier APK dans dist/ pour téléchargement copine via lien
- Tester détection langue avec "Bonjour" ET "你好"
- Vérifier scroll auto sur réception WebSocket
- VÉRIFIER que l'APK final contient TOUTES les modifications (tester avant de copier dans dist/)

TEMPS TOTAL ESTIMÉ : 50 minutes (code + build + test)

Aide-moi à implémenter ces 4 améliorations UX dans l'ordre de la TODO list. Merci !
```

---

## 📂 Fichiers Principaux à Modifier

### 1. `chat_controller.dart` (Logique)
**Lignes importantes** :
- ~52 : `build()` - Initialisation
- ~234 : `send()` - Envoi message (AJOUTER détection langue)
- ~251-260 : Création userMsg (SUPPRIMER pour masquer original)
- ~273-293 : Création replyMsg (AJOUTER scroll trigger)
- ~315-345 : `_receiveRemote()` - Réception WebSocket (AJOUTER scroll trigger)

### 2. `chat_page.dart` (Interface)
**Lignes importantes** :
- ~22-43 : `initState()` - Scroll initial au bas
- ~49-58 : AppBar - (AJOUTER badge rouge avec compteur)
- ~76-97 : ListView.builder - Liste messages
- ~81-96 : itemBuilder - (OPTION : filtrer messages isMe)
- ~108-121 : onSend callback - (VÉRIFIER scroll auto déjà là)

### 3. `badge_service.dart` (Si badge interne UI)
**Utilisation** :
```dart
BadgeService.currentCount  // Nombre messages non lus
BadgeService.increment()   // +1
BadgeService.clear()       // Reset à 0
```

---

## 🎨 Wireframe Attendu

### AVANT (Actuel)
```
[AppBar: FR → ZH] [🔄 Swap]

┌─────────────────────┐
│ "Bonjour"          │  ← Ma bulle (isMe=true)
│ (en petit italique) │
└─────────────────────┘

        ┌─────────────────────┐
        │ 你好                │  ← Bulle traduction (isMe=false)
        │ (ni hao)            │
        │ 16:04               │
        └─────────────────────┘

[TextField "Écrire..."] [📤 Envoyer]
```

### APRÈS (Attendu)
```
[AppBar: (Auto)] [🔔🔴3]
                  ↑ Badge rouge avec compteur (disparaît quand scroll bas)
                  (PAS de bouton swap, détection auto)

        ┌─────────────────────┐
        │ 你好                │  ← SEULEMENT la traduction
        │ (ni hao)            │  ← (1 bulle au lieu de 2)
        │ 16:04               │
        └─────────────────────┘
                                 ← Scroll auto vers ici
                                 ← Point rouge disparaît quand ici

[TextField "Écrire..."] [📤 Envoyer]
```

**Changements visuels** :
- ✅ Badge rouge avec nombre dans AppBar (disparaît auto quand lu)
- ✅ 1 bulle au lieu de 2 (plus clean)
- ✅ Scroll automatique vers bas
- ✅ Direction auto (titre change automatiquement)
- ✅ Bouton swap supprimé (détection auto suffit)

---

## 🧪 Scénarios de Test Complets

### Scénario 1 : Conversation Normale
```
1. MOI (téléphone) : Tape "Bonjour mon amour"
   → App détecte français
   → Traduit en chinois
   → ELLE reçoit "你好我的爱" (1 bulle)
   → Scroll auto vers bas ✅

2. ELLE (émulateur) : Tape "想你了"
   → App détecte chinois
   → Traduit en français
   → JE reçois "Tu me manques" (1 bulle)
   → Point rouge "1" apparaît dans AppBar ✅
   → Scroll auto vers bas ✅

3. MOI : Ouvre l'app
   → Point rouge disparaît ✅
   → Scroll auto vers message le plus récent ✅
```

### Scénario 2 : Messages Rapides
```
1. ELLE envoie 3 messages chinois rapidement
2. MOI : App fermée
3. MOI : Rouvre l'app
   → Point rouge "3" visible ✅
   → Scroll auto vers le bas (dernier message) ✅
   → Tous les messages traduits en français ✅
4. MOI : Scroll vers bas (lecture)
   → Point rouge disparaît ✅
```

### Scénario 3 : Mélange Langues
```
1. MOI : "Bonjour" → Traduit ZH ✅
2. MOI : "你好" → Traduit FR ✅ (détection auto change direction)
3. ELLE : "hello" → Détecte comme FR (pas de chinois) → Traduit ZH ✅
4. ELLE : "我爱你" → Détecte chinois → Traduit FR ✅
```

---

## 📊 Estimation Temps Session

| Tâche | Temps Code | Temps Build | Temps Test | Total |
|-------|-----------|-------------|-----------|-------|
| 1. Auto-scroll | 5 min | - | - | 5 min |
| 2. Détection langue | 15 min | - | - | 15 min |
| 3. Masquer original | 10 min | - | - | 10 min |
| 4. Badge rouge UI | 20 min | - | - | 20 min |
| **Build APK** | - | 3 min | - | 3 min |
| **Install + Test** | - | - | 7 min | 7 min |
| **TOTAL** | **50 min** | **3 min** | **7 min** | **60 min** |

**Session complète** : ~1 heure

---

## 🎯 Priorités si Manque de Temps

### Must-Have (30 min)
1. ✅ Détection auto langue (15 min) - Feature clé
2. ✅ Masquer original (10 min) - Améliore UX
3. ✅ Auto-scroll (5 min) - QoL essentiel

### Nice-to-Have (20 min)
4. ⭐ Point rouge interne (20 min) - Bonus

**Stratégie** : Faire 1-2-3 d'abord, build/test, puis 4 si temps restant

---

## ⚠️ Pièges à Éviter

### 1. **Oublier force-stop**
```bash
❌ install -r → lancer app directement
   = Ancien code tourne toujours !

✅ install -r → force-stop → start
   = Nouveau code chargé
```

### 2. **flutter clean par défaut**
```bash
❌ flutter clean && flutter build
   = 60-90 minutes perdu

✅ flutter build directement
   = 2-5 minutes
   
flutter clean SEULEMENT si :
- Logs montrent ancien code après install+restart
- Erreurs bizarres Gradle/Kotlin
```

### 3. **Modification sans rebuild**
```bash
❌ Modifier code → install même APK
   = Aucun changement visible

✅ Modifier code → flutter build → install nouveau APK
   = Changements visibles
```

### 4. **Détecter langue après envoi**
```dart
❌ send(text) → _detectLanguage()
   = Trop tard, déjà envoyé avec mauvaise direction

✅ _detectLanguage(text) → set direction → send()
   = Direction correcte avant traduction
```

---

## 💡 Astuces Implémentation

### Détection Langue
```dart
// Simple et fiable pour FR/ZH
bool _hasChineseChars(String text) {
  return RegExp(r'[\u4e00-\u9fff]').hasMatch(text);
}

// Dans send() :
if (_hasChineseChars(text)) {
  _sourceLang = 'zh';
  _targetLang = 'fr';
} else {
  _sourceLang = 'fr';
  _targetLang = 'zh';
}
```

### Auto-Scroll Après Update
```dart
// APRÈS state = [...state, newMsg]
ref.notifyListeners();
WidgetsBinding.instance.addPostFrameCallback((_) {
  if (_listCtrl.hasClients) {
    _listCtrl.animateTo(
      _listCtrl.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
});
```

### Badge Rouge UI
```dart
// Utiliser badges (package) pour l'UI interne
import 'package:badges/badges.dart' as badges;

badges.Badge(
  badgeContent: Text('$count'),
  showBadge: count > 0,
  child: Icon(Icons.notifications),
)
```

**OU** Stack manuel (pas de package) :
```dart
Stack(
  children: [
    Icon(Icons.notifications),
    if (count > 0)
      Positioned(
        right: 0, top: 0,
        child: Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
          child: Text('$count', style: TextStyle(color: Colors.white, fontSize: 10)),
        ),
      ),
  ],
)
```

---

## 🔍 Points d'Attention

### Scroll Controller
```dart
// chat_page.dart a déjà un ScrollController
final ScrollController _listCtrl = ScrollController();

// ATTENTION : Le passer à ChatController pour trigger scroll
// Ou : Trigger scroll dans chat_page après watch state change
```

### Badge Count Réactif
```dart
// Option 1 : Faire BadgeService un provider Riverpod
final badgeCountProvider = StateProvider<int>((ref) => 0);

// Option 2 : ref.notifyListeners() dans chat_controller après increment
// → Force rebuild de ChatPage
// → Badge compte se met à jour

// Option 3 : ValueListenableBuilder sur BadgeService.currentCount
```

### Messages isMe Logic
```dart
// Message que J'ENVOIE
final ChatMessage userMsg = ChatMessage(
  isMe: true,           // C'est moi qui envoie
  originalText: text,   // Ce que j'ai tapé
  translatedText: '',   // Pas encore traduit
);

// Traduction POUR L'AUTRE
final ChatMessage replyMsg = ChatMessage(
  isMe: false,          // Pas moi, c'est pour l'autre
  originalText: '',     // On garde vide (ou text pour référence)
  translatedText: res.translation,  // La traduction
);

// NOUVEAU COMPORTEMENT :
// NE créer QUE replyMsg (isMe=false)
// Comme ça, affiche seulement côté destinataire
```

---

## 📚 Références Code Existant

### chat_controller.dart - send() actuel
```dart
Future<void> send(String text, {bool broadcast = true}) async {
  // ... validations
  
  // ❌ SUPPRIMER CES LIGNES (userMsg)
  final ChatMessage userMsg = ChatMessage(
    id: DateTime.now().microsecondsSinceEpoch.toString(),
    originalText: text,
    translatedText: '',
    isMe: true,  // ← Crée bulle "moi"
    time: DateTime.now().toUtc(),
  );
  state = <ChatMessage>[...state, userMsg];
  await saveMessages();
  
  // Broadcast WebSocket ...
  
  // ✅ GARDER SEULEMENT replyMsg
  final TranslationResult res = await _repo.translate(...);
  final ChatMessage replyMsg = ChatMessage(
    id: (DateTime.now().microsecondsSinceEpoch + 1).toString(),
    originalText: '',  // ou text pour référence
    translatedText: res.translation,
    isMe: false,  // ← Affiche côté destinataire
    time: DateTime.now().toUtc(),
    pinyin: res.pinyin,
    notes: res.notes,
  );
  state = <ChatMessage>[...state, replyMsg];
  // ✅ AJOUTER ICI : Trigger scroll auto
}
```

### chat_page.dart - onSend actuel
```dart
onSend: () async {
  final text = _textCtrl.text;
  _textCtrl.clear();
  await ref.read(chatControllerProvider.notifier).send(text);
  
  // ✅ DÉJÀ PRÉSENT (ligne ~112-120)
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_listCtrl.hasClients) {
      _listCtrl.animateTo(
        _listCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  });
},
```
→ Scroll déjà fait pour envoi ! Juste besoin pour réception WebSocket.

---

## 🎁 Bonus : Améliorations Futures (Pas Urgent)

### Mode Silencieux (Session Suivante)
- Toggle son/vibration notifications
- Bouton dans AppBar
- Sauvegarde préférence

### Notification Permanente (Remplace Badge Icône)
- "X messages non lus" dans barre notification
- Ongoing notification
- Alternative au badge MIUI qui marche pas

### Clear Conversation
- Déjà un bouton clear ?
- Si non, ajouter dans menu AppBar

### Thème Clair/Sombre
- App est en dark mode actuellement
- Ajouter switch si besoin

---

## 📖 Leçons de la Session Précédente

### ✅ Ce qui a Marché
- Build optimisé (sans clean) : 2-5 min
- Workflow 2 devices : Maîtrisé
- Logs surveillance : Efficace
- Prompt traduction littéral : Amélioré

### ❌ Ce qui N'a PAS Marché
- Badges sur icône téléphone (MIUI incompatible)
- flutter_app_badger (obsolète)
- ShortcutBadger (retourne false)
- 4h perdues sur badges icône

### 💡 Leçon
**Ne PAS se battre contre le système**
- Si ça marche pas après 2-3 essais → Solution alternative
- Badges icône = pas fiable Android → Notification permanente ou badge UI interne

---

## ✅ Checklist Pré-Session

Avant de commencer, vérifier :

- [ ] Android Studio lancé (pour émulateur)
- [ ] Émulateur Chat API30lite démarré
- [ ] Téléphone connecté USB (câble branché)
- [ ] Débogage USB activé sur téléphone
- [ ] Variables env présentes : `echo $env:OPENAI_API_KEY`
- [ ] Terminal PowerShell dans le bon dossier : `cd "C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai\qwen_chat_openai"`

**Vérification rapide** :
```powershell
cd "C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai\qwen_chat_openai"
adb devices
echo $env:OPENAI_API_KEY
```

Si tout OK → Copier-coller le PROMPT ci-dessus ! 🚀

---

## 📊 Résumé Exécutif

**4 Modifications UX** :
1. 📜 Auto-scroll → Messages toujours visibles
2. 🌍 Détection langue → Plus de swap manuel
3. 💬 1 bulle au lieu de 2 → Conversation plus claire
4. 🔴 Point rouge interne → Compteur messages non lus

**Temps** : ~1 heure  
**Difficulté** : Facile (aucun combat contre système)  
**Fichiers** : 2 principaux (chat_controller.dart + chat_page.dart)  
**Impact UX** : 🚀 ÉNORME (app beaucoup plus fluide)

---

---

## 🎁 ÉTAPE FINALE : APK pour Téléchargement Copine

### Validation Complète AVANT de Copier

**Checklist de validation** :
```
[ ] Auto-scroll fonctionne (envoi + réception)
[ ] Détection langue fonctionne (FR et ZH testés)
[ ] 1 seule bulle par message (pas 2)
[ ] Bouton swap supprimé de l'AppBar
[ ] Point rouge apparaît quand nouveau message
[ ] Point rouge disparaît quand scroll en bas
[ ] Messages synchronisés entre téléphone et émulateur
[ ] Traduction fonctionne correctement
```

### Copie dans dist/

```powershell
# Une fois TOUT validé sur téléphone ET émulateur :

# Créer dossier dist si n'existe pas
New-Item -ItemType Directory -Force -Path dist

# Copier APK final avec date
$date = Get-Date -Format "yyyyMMdd"
copy build\app\outputs\flutter-apk\app-release.apk "dist\XiaoXin002-release-$date.apk"

# Ou nom simple pour lien fixe
copy build\app\outputs\flutter-apk\app-release.apk dist\XiaoXin002-latest.apk

# Vérifier taille (devrait être ~46 MB)
dir dist\*.apk
```

### Partage avec Copine

**Fichier à partager** : `dist/XiaoXin002-latest.apk` ou `dist/XiaoXin002-release-YYYYMMDD.apk`

**Options de partage** :
1. **Upload sur serveur web** (si vous avez)
2. **Google Drive / Dropbox** → Générer lien de téléchargement direct
3. **WeTransfer** → Lien temporaire
4. **GitHub Release** → Si projet sur GitHub

**Instructions pour elle** :
```
1. Télécharger XiaoXin002-latest.apk
2. Activer "Sources inconnues" dans paramètres Android
3. Ouvrir le fichier APK → Installer
4. Lancer XiaoXin002
5. Taper en chinois → Ça traduit automatiquement en français !
```

---

**C'est parti pour la prochaine session !** 🎉


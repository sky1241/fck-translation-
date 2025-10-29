# ⚡ WORKFLOW DE DÉVELOPPEMENT RAPIDE

**Date** : 18 Octobre 2025  
**Objectif** : Gagner du temps lors des modifications UI/code en évitant les builds longs

---

## 🎯 LE PROBLÈME

**Workflow actuel (lent)** :
```
Modifier code → flutter build apk (2-35 min) → install → force-stop → start
= 3-40 minutes par test 😭
```

**Problèmes observés** :
- ❌ Build incrémental parfois ne prend PAS les modifications
- ❌ Supprimer `build/` prend 30-35 min
- ❌ `flutter clean` prend 60-90 min
- ❌ Impossible de tester rapidement des petits changements

---

## ✅ LA SOLUTION : Développer en MODE DEBUG avec Hot Reload

### Option 1 : Mode Debug avec Hot Reload (RECOMMANDÉ pour dev)

**Avantages** :
- ✅ Hot Reload : **1-3 secondes** pour voir les changements !
- ✅ Hot Restart : **5-10 secondes** pour recharger l'app
- ✅ Modifications instantanées
- ✅ Logs en temps réel

**Inconvénients** :
- ⚠️ App plus lente (pas optimisée)
- ⚠️ APK plus gros (~50-60 MB vs 46 MB)
- ⚠️ Mode debug visible (banner "DEBUG")

**Comment l'utiliser** :

```powershell
# 1. Connecter le téléphone
adb devices

# 2. Lancer en mode debug (avec hot reload)
flutter run --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY --dart-define=OPENAI_PROJECT=$env:OPENAI_PROJECT --dart-define=OPENAI_MODEL=gpt-4o-mini --dart-define=RELAY_WS_URL=wss://fck-relay-ws.onrender.com --dart-define=RELAY_ROOM=demo123

# 3. App se lance sur le téléphone

# 4. Modifier le code (ex: chat_page.dart)

# 5. Hot Reload : Appuyer sur 'r' dans le terminal
# Ou : Sauvegarder le fichier (VS Code fait hot reload auto)
# = Changements visibles en 1-3 secondes ! ⚡

# 6. Hot Restart (si besoin de recharger l'état) : Appuyer sur 'R'
# = Redémarrage complet en 5-10 secondes

# 7. Quitter : Appuyer sur 'q' dans le terminal
```

**Commandes utiles pendant `flutter run`** :
- `r` : Hot Reload (recharge le code, garde l'état)
- `R` : Hot Restart (recharge tout, reset l'état)
- `p` : Afficher le widget tree
- `o` : Toggle platform (Android/iOS)
- `q` : Quitter
- `h` : Aide

---

### Option 2 : Build Release Final (pour prod/distribution)

**Quand l'utiliser** :
- ✅ Tests finaux avant partage
- ✅ APK à donner à la copine
- ✅ Performance réelle à tester

**Workflow** :

```powershell
# 1. Développer en mode debug avec hot reload (Option 1)
# = Gagner 95% du temps de développement

# 2. Une fois satisfait, build release FINAL
Remove-Item -Recurse -Force build  # Si problème de cache
flutter build apk --release --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY --dart-define=OPENAI_PROJECT=$env:OPENAI_PROJECT --dart-define=OPENAI_MODEL=gpt-4o-mini --dart-define=RELAY_WS_URL=wss://fck-relay-ws.onrender.com --dart-define=RELAY_ROOM=demo123

# 3. Installer et tester
adb -s FMMFSOOBXO8T5D75 install -r build\app\outputs\flutter-apk\app-release.apk
adb -s FMMFSOOBXO8T5D75 shell am force-stop com.example.qwen_chat_openai
adb -s FMMFSOOBXO8T5D75 shell am start -n com.example.qwen_chat_openai/.MainActivity

# 4. Copier dans dist/ pour partage
copy build\app\outputs\flutter-apk\app-release.apk dist\XiaoXin002-latest.apk
```

---

## 📊 COMPARAISON DES WORKFLOWS

| Workflow | Temps par modif | Quand utiliser | Hot Reload |
|----------|----------------|----------------|------------|
| **flutter run (debug)** | **1-10 sec** ⚡ | Développement actif | ✅ OUI |
| Build incrémental | 2-7 min | - | ❌ NON |
| Supprimer build/ | 30-35 min | Cache corrompu | ❌ NON |
| flutter clean | 60-90 min | Dernier recours | ❌ NON |

**Gain de temps** : 95% en utilisant `flutter run` pendant le développement !

---

## 🎯 WORKFLOW RECOMMANDÉ COMPLET

### Phase 1 : Développement (90% du temps)

```powershell
# Lancer une fois
flutter run [... toutes les --dart-define ...]

# Puis modifier le code librement
# Chaque sauvegarde = Hot Reload automatique (1-3 sec)
# Appuyer sur 'r' si besoin
# Appuyer sur 'R' pour reset l'état complet

# = Tester 20-30 modifications en 5 minutes ! 🚀
```

### Phase 2 : Validation Finale (5% du temps)

```powershell
# Quitter flutter run : 'q'

# Build release
flutter build apk --release [...]

# Install
adb -s FMMFSOOBXO8T5D75 install -r build\app\outputs\flutter-apk\app-release.apk
adb -s FMMFSOOBXO8T5D75 shell am force-stop com.example.qwen_chat_openai
adb -s FMMFSOOBXO8T5D75 shell am start -n com.example.qwen_chat_openai/.MainActivity
```

### Phase 3 : Distribution (5% du temps)

```powershell
# Copier APK pour partage
copy build\app\outputs\flutter-apk\app-release.apk dist\XiaoXin002-latest.apk
# Upload sur Drive/WeTransfer pour la copine
```

---

## ⚠️ PIÈGES À ÉVITER

### 1. Ne PAS utiliser hot reload pour certains changements

Hot reload **NE MARCHE PAS** pour :
- ❌ Changements dans `main()` ou `initState()`
- ❌ Ajout de nouveaux assets
- ❌ Changements dans `pubspec.yaml`
- ❌ Changements dans code natif (Kotlin/Swift)

**Solution** : Utiliser Hot Restart (`R`) ou relancer `flutter run`

### 2. Toujours faire force-stop après install

```powershell
# ❌ MAUVAIS
adb install -r app.apk
# = Ancien code reste en mémoire

# ✅ BON
adb install -r app.apk
adb shell am force-stop com.example.qwen_chat_openai
adb shell am start -n com.example.qwen_chat_openai/.MainActivity
```

### 3. Vérifier les clés API en mode debug

Les `--dart-define` doivent être passés à `flutter run` aussi, sinon l'app n'aura pas les clés API !

---

## 💡 ASTUCES SUPPLÉMENTAIRES

### Accélérer encore plus : Split APK par architecture

```powershell
# Build seulement pour ARM64 (téléphones récents)
flutter build apk --release --target-platform android-arm64 --split-per-abi

# Résultat : 3 APK générés (arm, arm64, x86_64)
# Prendre seulement app-arm64-v8a-release.apk (~30 MB au lieu de 46 MB)
# = Build ~20% plus rapide
```

### Utiliser un émulateur pour dev si le téléphone pas dispo

```powershell
# Lancer émulateur
emulator -avd Chat_API30lite

# Puis flutter run cible automatiquement l'émulateur
flutter run [...]
```

### Logs en temps réel

```powershell
# Pendant flutter run, les logs s'affichent automatiquement

# Ou dans un autre terminal :
adb logcat -c  # Clear
adb logcat | Select-String -Pattern "flutter|qwen"
```

---

## 📈 RÉSULTATS ATTENDUS

**Avant (workflow lent)** :
- 10 modifications UI = 10 × 30 min = **5 heures** 😭

**Après (workflow rapide)** :
- 10 modifications UI = 10 × 10 sec = **2 minutes** 🚀
- 1 build release final = 30 min
- **Total : ~32 minutes** (gain de 93% !)

---

## ✅ CHECKLIST RAPIDE

**Pour développer rapidement** :
- [ ] `flutter run` avec les --dart-define
- [ ] Modifier le code
- [ ] Sauvegarder = Hot Reload auto
- [ ] Appuyer sur `r` ou `R` si besoin
- [ ] Répéter jusqu'à satisfaction

**Pour distribuer** :
- [ ] Quitter `flutter run` (appuyer sur `q`)
- [ ] `flutter build apk --release`
- [ ] Installer sur téléphone avec force-stop
- [ ] Tester
- [ ] Copier dans dist/
- [ ] Partager avec la copine

---

**Créé le** : 18 Octobre 2025  
**Auteur** : AI Assistant  
**Gain de temps** : 93-95% pendant le développement


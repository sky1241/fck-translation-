# 🚀 MASTER TEMPLATE FLUTTER - TOUT EN UN

**Version** : 1.0 (18 Oct 2025)  
**Source** : Projet XiaoXin002  
**Gain de temps** : 90-95% sur chaque nouveau projet

---

## 📋 PROMPT À ME DONNER POUR NOUVEAU PROJET

```
Nouveau projet Flutter : [NOM]

Applique le MASTER TEMPLATE :
C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai\qwen_chat_openai\docs\MASTER_TEMPLATE.md

Setup tout automatiquement. Go !
```

---

## ⚙️ CONFIG OBLIGATOIRE (À FAIRE SYSTÉMATIQUEMENT)

### 1. Gradle Config

**`android/app/build.gradle.kts`**
```kotlin
buildTypes {
    release {
        isMinifyEnabled = false      // IMPORTANT : Évite deadlocks
        isShrinkResources = false
    }
}
```

**`android/gradle.properties`**
```properties
org.gradle.caching=true
org.gradle.parallel=true
org.gradle.daemon=true
org.gradle.jvmargs=-Xmx4096m -XX:MaxMetaspaceSize=1024m
```

---

## ⚡ WORKFLOW DÉVELOPPEMENT

### Mode DEV (90% du temps)

```powershell
# Lancer UNE FOIS
flutter run [--dart-define=... si API]

# Modifier code → Sauvegarder → Hot Reload AUTO (1-3 sec) ⚡
# Appuyer 'r' pour forcer reload
# Appuyer 'R' pour restart app
# Appuyer 'q' pour quitter
```

### Mode RELEASE (10% du temps)

```powershell
# Build release
flutter build apk --release [--dart-define=...]

# Install sur device
adb -s DEVICE_ID install -r build\app\outputs\flutter-apk\app-release.apk
adb -s DEVICE_ID shell am force-stop package.name
adb -s DEVICE_ID shell am start -n package.name/.MainActivity
```

---

## 🔧 GESTION DU CACHE

### Si modifs pas reflétées dans l'APK

```powershell
# Option 1 : Build normal (2-7 min)
flutter build apk --release

# Option 2 : Supprimer build/ (30 min)
Remove-Item -Recurse -Force build
flutter build apk --release

# Option 3 : flutter clean (60-90 min - DERNIER RECOURS)
flutter clean
flutter pub get
flutter build apk --release
```

**Règle** : JAMAIS `flutter clean` par défaut !

---

## 📝 LEÇONS CRITIQUES

### 1. Hot Reload = 93% de gain de temps
- Utiliser `flutter run` pour dev
- Build release seulement pour tests finaux

### 2. TOUJOURS faire force-stop après install
```powershell
adb install -r app.apk
adb shell am force-stop package.name  # OBLIGATOIRE
adb shell am start -n package.name/.MainActivity
```

### 3. Désactiver minify en release
- Évite les deadlocks R8 sur Windows
- Build plus stable

### 4. Activer cache Gradle
- 20-30% plus rapide
- Builds incrémentiels efficaces

### 5. Ne pas commit secrets
- Utiliser `--dart-define`
- Variables env : `$env:MA_CLE`

---

## 📊 TEMPS DE BUILD ATTENDUS

| Action | Temps | Quand utiliser |
|--------|-------|----------------|
| Hot reload | 1-3 sec | Dev quotidien ⚡ |
| Build incrémental | 2-7 min | Test release |
| Supprimer build/ | 30-35 min | Cache corrompu |
| flutter clean | 60-90 min | Dernier recours |

---

## ✅ CHECKLIST NOUVEAU PROJET

- [ ] Config Gradle (minify=false, cache=true)
- [ ] Tester `flutter run` + hot reload
- [ ] Créer scripts/dev.ps1, build.ps1, deploy.ps1
- [ ] Créer dist/ pour APK finaux
- [ ] Setup .gitignore (secrets)

---

## 🚀 SCRIPTS RAPIDES

### dev.ps1
```powershell
flutter run --dart-define=MA_CLE=$env:MA_CLE
```

### build.ps1
```powershell
flutter build apk --release --dart-define=MA_CLE=$env:MA_CLE
Copy-Item build\app\outputs\flutter-apk\app-release.apk "dist\app-$(Get-Date -Format 'yyyyMMdd').apk"
```

### deploy.ps1
```powershell
param([string]$device, [string]$package)
adb -s $device install -r build\app\outputs\flutter-apk\app-release.apk
adb -s $device shell am force-stop $package
adb -s $device shell am start -n $package/.MainActivity
```

---

## 💡 ERREURS À NE PLUS FAIRE

❌ `flutter clean` par défaut  
❌ Build release pour chaque modif  
❌ Install sans force-stop  
❌ Commit secrets dans git  
❌ Ignorer les logs d'erreur  

✅ `flutter run` pour dev  
✅ Build release en fin de journée  
✅ TOUJOURS force-stop  
✅ Utiliser --dart-define  
✅ Documenter problèmes résolus  

---

**FIN DU TEMPLATE - Gain : 90-95% sur chaque projet** 🚀


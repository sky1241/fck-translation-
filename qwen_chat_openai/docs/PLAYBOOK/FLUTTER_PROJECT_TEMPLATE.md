# 📦 TEMPLATE DE BASE FLUTTER - À COPIER POUR CHAQUE NOUVEAU PROJET

**Date de création** : 18 Octobre 2025  
**Source** : Leçons apprises du projet XiaoXin002  
**Objectif** : Gagner 80-95% du temps sur les nouveaux projets Flutter

---

## 🎯 COMMENT UTILISER CE TEMPLATE

### Option 1 : Copier les fichiers docs dans le nouveau projet

```powershell
# 1. Créer nouveau projet Flutter
flutter create mon_nouveau_projet
cd mon_nouveau_projet

# 2. Copier le dossier docs/ depuis XiaoXin002
Copy-Item -Recurse "C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai\qwen_chat_openai\docs" .\docs

# 3. Adapter les fichiers selon le nouveau projet
# - Modifier LESSONS_LEARNED.md
# - Modifier WORKFLOW_RAPIDE_DEV.md avec les nouvelles clés API
```

### Option 2 : Créer un template git réutilisable (RECOMMANDÉ)

```powershell
# 1. Créer un repo template sur GitHub
# 2. Pusher le dossier docs/ dedans
# 3. Pour chaque nouveau projet, cloner le template
# 4. Adapter selon besoin
```

---

## 📋 FICHIERS ESSENTIELS À COPIER

### Fichiers de documentation (docs/)

| Fichier | Description | Priorité |
|---------|-------------|----------|
| `LESSONS_LEARNED.md` | ⭐⭐⭐ Toutes les leçons critiques | **OBLIGATOIRE** |
| `WORKFLOW_RAPIDE_DEV.md` | ⭐⭐⭐ Comment développer rapidement | **OBLIGATOIRE** |
| `PLAYBOOK/TROUBLESHOOTING.md` | ⭐⭐ Solutions aux problèmes courants | Recommandé |
| `FLUTTER_FAST_DEV_GUIDE.md` | ⭐⭐ Guide de développement rapide | Recommandé |
| `PROMPT_NOUVELLE_SESSION.md` | ⭐ Template pour briefer l'AI | Utile |

### Fichiers de configuration (à adapter)

| Fichier | Description | Action |
|---------|-------------|--------|
| `android/app/build.gradle.kts` | Config Android | Copier + adapter |
| `android/gradle.properties` | Cache Gradle | Copier tel quel |
| `.gitignore` | Fichiers à ignorer | Copier + adapter |

---

## ⚡ LEÇONS CRITIQUES À APPLIQUER IMMÉDIATEMENT

### 1. Configuration Gradle (Éviter les builds lents)

**Fichier** : `android/app/build.gradle.kts`

```kotlin
android {
    buildTypes {
        release {
            // IMPORTANT : Désactiver minify pour éviter les deadlocks R8
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}
```

**Fichier** : `android/gradle.properties`

```properties
# Activer le cache Gradle
org.gradle.caching=true
org.gradle.parallel=true
org.gradle.daemon=true

# Augmenter la mémoire allouée
org.gradle.jvmargs=-Xmx4096m -XX:MaxMetaspaceSize=1024m
```

**Gain** : 20-40% de temps sur les builds

---

### 2. Workflow de Développement (Gagner 93% du temps)

**Phase 1 : Développement (90% du temps)**

```powershell
# Lancer en mode debug avec hot reload
cd votre_projet
flutter run [--dart-define=... si besoin]

# Modifier le code
# Sauvegarder = Hot Reload auto (1-3 sec) ⚡
# Appuyer sur 'r' pour forcer hot reload
# Appuyer sur 'R' pour hot restart
```

**Phase 2 : Build Release (10% du temps)**

```powershell
# Quand satisfait, build release
flutter build apk --release [--dart-define=...]

# Installer sur device
adb -s <DEVICE_ID> install -r build/app/outputs/flutter-apk/app-release.apk
adb -s <DEVICE_ID> shell am force-stop <package.name>
adb -s <DEVICE_ID> shell am start -n <package.name>/.MainActivity
```

**Gain** : 93-95% du temps de développement

---

### 3. Gestion du Cache (Éviter les problèmes de build)

**Problème** : Modifications pas reflétées dans l'APK

**Solutions par ordre de rapidité** :

```powershell
# 1. Build incrémental normal (2-7 min)
flutter build apk --release

# 2. Si pas de changements visibles : Supprimer build/ (30-35 min)
Remove-Item -Recurse -Force build
flutter build apk --release

# 3. Dernier recours : flutter clean (60-90 min)
flutter clean
flutter pub get
flutter build apk --release
```

**Règle d'or** : NE JAMAIS faire `flutter clean` par défaut !

---

### 4. Installation sur Device (TOUJOURS faire force-stop)

```powershell
# ❌ MAUVAIS (ancien code reste en mémoire)
adb install -r app.apk

# ✅ BON (force le rechargement)
adb install -r app.apk
adb shell am force-stop <package.name>
adb shell am start -n <package.name>/.MainActivity
```

---

## 🎯 CHECKLIST DÉBUT DE PROJET

### Avant de coder

- [ ] Copier `docs/` depuis XiaoXin002
- [ ] Configurer `android/app/build.gradle.kts` (désactiver minify)
- [ ] Configurer `android/gradle.properties` (activer cache)
- [ ] Créer `.gitignore` adapté (ne pas commit secrets)
- [ ] Lire `LESSONS_LEARNED.md` en entier
- [ ] Lire `WORKFLOW_RAPIDE_DEV.md`

### Pendant le développement

- [ ] Utiliser `flutter run` en mode debug
- [ ] Hot reload constant (1-3 sec par modif)
- [ ] Ne build release que pour tests finaux
- [ ] TOUJOURS faire force-stop après install

### Avant distribution

- [ ] Build release final
- [ ] Tester sur device physique
- [ ] Vérifier que toutes les modifs sont présentes
- [ ] Copier APK dans `dist/` pour partage

---

## 📊 GAINS DE TEMPS ATTENDUS

| Tâche | Sans template | Avec template | Gain |
|-------|--------------|---------------|------|
| Setup projet | 2-4h | 30 min | **75%** |
| Développement UI | 5h (builds répétés) | 30 min (hot reload) | **90%** |
| Debug problèmes build | 2-3h | 20 min | **85%** |
| Distribution APK | 1h | 15 min | **75%** |
| **TOTAL** | **10-13h** | **1h35** | **87%** |

---

## 🎨 STRUCTURE DE PROJET RECOMMANDÉE

```
mon_projet/
├── docs/                          # Documentation
│   ├── LESSONS_LEARNED.md         # Leçons apprises (à adapter)
│   ├── WORKFLOW_RAPIDE_DEV.md     # Workflow rapide (copier tel quel)
│   ├── DAILY_REPORT_YYYY-MM-DD.md # Rapports quotidiens
│   └── PLAYBOOK/
│       ├── TROUBLESHOOTING.md     # Solutions problèmes
│       ├── COMMANDS.ps1           # Commandes utiles
│       └── CHECKLIST.md           # Checklists projet
├── lib/
│   ├── core/                      # Code partagé
│   │   ├── env/                   # Variables environnement
│   │   ├── network/               # Services réseau
│   │   └── utils/                 # Utilitaires
│   ├── features/                  # Features (modules)
│   │   └── [feature_name]/
│   │       ├── data/             # Repositories, models
│   │       ├── domain/           # Logique métier
│   │       └── presentation/     # UI, controllers
│   └── main.dart
├── android/
│   ├── app/
│   │   └── build.gradle.kts       # ⚠️ Configurer minify = false
│   └── gradle.properties          # ⚠️ Configurer cache = true
├── dist/                          # APK finaux pour distribution
├── .gitignore                     # Ne pas commit secrets
└── pubspec.yaml
```

---

## 🔧 SCRIPTS UTILES À CRÉER

### `scripts/quick_build.ps1`

```powershell
# Build rapide avec toutes les options
param(
    [string]$mode = "release"
)

Write-Host "🏗️ Building in $mode mode..."

if ($mode -eq "debug") {
    flutter run --dart-define=MY_KEY=$env:MY_KEY
} else {
    flutter build apk --release --dart-define=MY_KEY=$env:MY_KEY
    Write-Host "✅ APK built: build\app\outputs\flutter-apk\app-release.apk"
}
```

### `scripts/deploy_device.ps1`

```powershell
# Deploy sur device avec force-stop
param(
    [string]$device = "DEVICE_ID",
    [string]$package = "com.example.myapp"
)

Write-Host "📱 Installing on $device..."
adb -s $device install -r build\app\outputs\flutter-apk\app-release.apk

Write-Host "🛑 Force stopping..."
adb -s $device shell am force-stop $package

Write-Host "🚀 Starting app..."
adb -s $device shell am start -n $package/.MainActivity

Write-Host "✅ Deployment complete!"
```

---

## 💡 BONNES PRATIQUES

### Sécurité

- ✅ Ne JAMAIS commit les clés API
- ✅ Utiliser `--dart-define` pour les secrets
- ✅ Ajouter `*.properties` dans `.gitignore`
- ✅ Variables env Windows : `$env:MA_CLE`

### Organisation

- ✅ Un rapport quotidien (`DAILY_REPORT_YYYY-MM-DD.md`)
- ✅ Documenter CHAQUE problème résolu
- ✅ Tenir à jour `LESSONS_LEARNED.md`
- ✅ Copier APK final dans `dist/` avec date

### Performance

- ✅ Désactiver minify en release (évite deadlocks)
- ✅ Activer cache Gradle
- ✅ Utiliser `flutter run` pour dev
- ✅ Ne build release que pour validation finale

---

## 🚨 ERREURS À NE JAMAIS REFAIRE

### ❌ Faire `flutter clean` par défaut
→ ✅ Seulement en dernier recours

### ❌ Build release pour chaque petite modif
→ ✅ Utiliser `flutter run` avec hot reload

### ❌ Installer APK sans force-stop
→ ✅ TOUJOURS faire force-stop puis start

### ❌ Commit les secrets dans git
→ ✅ Utiliser `--dart-define` et variables env

### ❌ Ne pas documenter les problèmes résolus
→ ✅ Ajouter dans `LESSONS_LEARNED.md`

---

## 📚 RESSOURCES UTILES

### Documentation à lire AVANT de commencer

1. `LESSONS_LEARNED.md` - Toutes les leçons (30 min)
2. `WORKFLOW_RAPIDE_DEV.md` - Workflow rapide (10 min)
3. `PLAYBOOK/TROUBLESHOOTING.md` - Solutions problèmes (15 min)

### Commandes à mémoriser

```powershell
# Dev rapide
flutter run

# Build release
flutter build apk --release

# Nettoyer cache (rare)
Remove-Item -Recurse -Force build

# Deploy sur device
adb install -r app.apk && adb shell am force-stop <package> && adb shell am start -n <package>/.MainActivity

# Logs temps réel
adb logcat | Select-String -Pattern "flutter"
```

---

## ✅ VALIDATION FINALE

Avant de considérer le template fonctionnel, vérifier :

- [ ] Build incrémental < 10 min
- [ ] Hot reload fonctionne (1-3 sec)
- [ ] Force-stop fonctionne après install
- [ ] Pas de deadlocks Gradle/R8
- [ ] Documentation claire et complète
- [ ] Scripts de build/deploy fonctionnent
- [ ] APK final dans dist/

---

## 🎉 RÉSULTAT ATTENDU

Avec ce template appliqué :
- ✅ Setup projet : **30 min** (au lieu de 4h)
- ✅ Développement : **93% plus rapide** (hot reload)
- ✅ Moins de bugs : **Documentation claire**
- ✅ Distribution : **Automatisée** (scripts)

**Gain total : 85-95% du temps de développement !** 🚀

---

**Créé le** : 18 Octobre 2025  
**Basé sur** : Projet XiaoXin002 (3 semaines de leçons)  
**Auteur** : AI Assistant  
**Version** : 1.0


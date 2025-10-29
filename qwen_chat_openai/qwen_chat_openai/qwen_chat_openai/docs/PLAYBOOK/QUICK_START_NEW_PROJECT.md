# 🚀 QUICK START - NOUVEAU PROJET FLUTTER

**Pour l'AI Assistant** : Ce fichier est à lire au début de CHAQUE nouveau projet Flutter

---

## 📋 PROMPT À UTILISER EN DÉBUT DE PROJET

```
Salut ! Je commence un nouveau projet Flutter [NOM DU PROJET].

Avant de coder, peux-tu :
1. Copier la structure de documentation depuis le projet XiaoXin002
2. Adapter LESSONS_LEARNED.md pour ce nouveau projet
3. Configurer android/app/build.gradle.kts (minify = false)
4. Configurer android/gradle.properties (cache = true)
5. Me rappeler d'utiliser flutter run pour le dev (hot reload)

Localisation du template :
C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai\qwen_chat_openai\docs\

Applique TOUTES les leçons apprises du projet XiaoXin002 automatiquement.
```

---

## ✅ CHECKLIST OBLIGATOIRE DÉBUT DE PROJET

### 1. Copier la documentation

```powershell
# Depuis le dossier du nouveau projet
Copy-Item -Recurse "C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai\qwen_chat_openai\docs\PLAYBOOK" .\docs\PLAYBOOK
Copy-Item "C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai\qwen_chat_openai\docs\LESSONS_LEARNED.md" .\docs\
Copy-Item "C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai\qwen_chat_openai\docs\WORKFLOW_RAPIDE_DEV.md" .\docs\
```

### 2. Configurer Gradle (OBLIGATOIRE)

**Fichier** : `android/app/build.gradle.kts`

```kotlin
buildTypes {
    release {
        isMinifyEnabled = false      // ⚠️ IMPORTANT
        isShrinkResources = false    // ⚠️ IMPORTANT
    }
}
```

**Fichier** : `android/gradle.properties`

```properties
org.gradle.caching=true
org.gradle.parallel=true
org.gradle.daemon=true
org.gradle.jvmargs=-Xmx4096m -XX:MaxMetaspaceSize=1024m
```

### 3. Créer la structure de dossiers

```
mon_projet/
├── docs/
│   ├── LESSONS_LEARNED.md
│   ├── WORKFLOW_RAPIDE_DEV.md
│   ├── DAILY_REPORT_[DATE].md
│   └── PLAYBOOK/
├── dist/
├── scripts/
└── [code flutter standard]
```

---

## 🎯 RÈGLES D'OR À SUIVRE

### Pendant le développement

1. ✅ **TOUJOURS utiliser `flutter run` en mode debug**
   - Hot reload = 1-3 secondes par modification
   - Gain de 93% du temps

2. ✅ **NE JAMAIS faire `flutter clean` par défaut**
   - Seulement en dernier recours
   - Préférer `Remove-Item -Recurse -Force build`

3. ✅ **TOUJOURS faire force-stop après install**
   ```powershell
   adb install -r app.apk
   adb shell am force-stop <package>
   adb shell am start -n <package>/.MainActivity
   ```

4. ✅ **Documenter CHAQUE problème résolu**
   - Ajouter dans `LESSONS_LEARNED.md`
   - Éviter de refaire les mêmes erreurs

### Avant distribution

1. ✅ Build release final seulement quand satisfait
2. ✅ Tester sur device physique
3. ✅ Copier APK dans `dist/` avec date
4. ✅ Vérifier que TOUTES les modifications sont présentes

---

## 📝 TEMPLATE DAILY REPORT

Créer un fichier `docs/DAILY_REPORT_YYYY-MM-DD.md` à chaque session :

```markdown
# 📅 RAPPORT QUOTIDIEN - [DATE]

## ✅ Ce qui a été fait

- [ ] Task 1
- [ ] Task 2

## ❌ Problèmes rencontrés

**Problème** : Description
**Solution** : Comment résolu
**Temps perdu** : XX minutes

## 📚 Leçons apprises

- Leçon 1
- Leçon 2

## 📊 Temps passé

- Développement : XX min
- Debug : XX min  
- Build/Deploy : XX min
- **Total** : XX min

## 🎯 Prochaines étapes

- [ ] Task pour demain 1
- [ ] Task pour demain 2
```

---

## 🔧 SCRIPTS À CRÉER

### `scripts/dev.ps1` - Lancer en mode dev

```powershell
flutter run --dart-define=MA_CLE=$env:MA_CLE
```

### `scripts/build.ps1` - Build release

```powershell
flutter build apk --release --dart-define=MA_CLE=$env:MA_CLE
Copy-Item build\app\outputs\flutter-apk\app-release.apk "dist\app-$(Get-Date -Format 'yyyyMMdd').apk"
```

### `scripts/deploy.ps1` - Deploy sur device

```powershell
param([string]$device, [string]$package)
adb -s $device install -r build\app\outputs\flutter-apk\app-release.apk
adb -s $device shell am force-stop $package
adb -s $device shell am start -n $package/.MainActivity
```

---

## 💡 RAPPELS IMPORTANTS

### Temps de build attendus

- `flutter run` initial : 3-5 min
- Hot reload : **1-3 sec** ⚡
- Build release : 2-7 min (incrémental)
- Supprimer build/ : 30-35 min
- flutter clean : 60-90 min (à éviter !)

### Quand utiliser quoi

| Situation | Commande | Temps |
|-----------|----------|-------|
| Dev normal | `flutter run` | 1-3 sec/modif |
| Test final | `flutter build apk --release` | 2-7 min |
| Modifs pas prises en compte | Supprimer `build/` | 30-35 min |
| Erreurs Gradle bizarres | `flutter clean` | 60-90 min |

---

## 🎯 OBJECTIFS POUR CHAQUE PROJET

- ✅ Setup en moins de 30 minutes
- ✅ Hot reload fonctionnel dès le début
- ✅ Documentation à jour quotidiennement
- ✅ Zéro problème de build/cache évitable
- ✅ Distribution automatisée via scripts

---

## 📚 FICHIERS À LIRE AVANT DE COMMENCER

1. **OBLIGATOIRE** : `LESSONS_LEARNED.md` (30 min)
2. **OBLIGATOIRE** : `WORKFLOW_RAPIDE_DEV.md` (10 min)
3. Recommandé : `PLAYBOOK/TROUBLESHOOTING.md` (15 min)
4. Recommandé : `FLUTTER_PROJECT_TEMPLATE.md` (20 min)

**Temps total** : 1h15 (une seule fois, gain de 10-20h sur le projet)

---

## ✅ VALIDATION QUE TOUT EST PRÊT

Avant de commencer à coder, vérifier :

- [ ] Documentation copiée dans `docs/`
- [ ] Gradle configuré (minify = false, cache = true)
- [ ] Structure de dossiers créée
- [ ] Scripts créés dans `scripts/`
- [ ] Device connecté et détecté (`adb devices`)
- [ ] Variables environnement configurées
- [ ] `flutter run` fonctionne
- [ ] Hot reload fonctionne (tester avec une modif simple)

---

**Une fois validé, tu peux coder 10-20x plus vite ! 🚀**

---

**Créé le** : 18 Octobre 2025  
**Pour** : Tous les futurs projets Flutter  
**Gain de temps** : 85-95% sur chaque projet


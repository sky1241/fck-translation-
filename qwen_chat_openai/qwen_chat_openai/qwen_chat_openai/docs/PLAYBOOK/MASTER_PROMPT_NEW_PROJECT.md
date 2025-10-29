# 🎯 PROMPT MASTER - NOUVEAU PROJET FLUTTER

**À copier-coller au début de CHAQUE nouveau projet**

---

## 📋 PROMPT À UTILISER (Copier-Coller)

```
Salut ! Je démarre un nouveau projet Flutter : [NOM DU PROJET]

Objectif : [DESCRIPTION COURTE - ex: App de chat, Todo list, etc.]

Applique le TEMPLATE depuis XiaoXin002 :
📂 C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai\qwen_chat_openai\docs\

Actions à faire automatiquement :

1️⃣ SETUP RAPIDE
   - Créer structure docs/ minimale (pas tout copier, juste l'essentiel)
   - Copier LESSONS_LEARNED.md (adapté au nouveau projet)
   - Copier WORKFLOW_RAPIDE_DEV.md (tel quel)

2️⃣ CONFIG GRADLE
   - android/app/build.gradle.kts : minify = false, shrink = false
   - android/gradle.properties : cache = true, parallel = true

3️⃣ SCRIPTS
   - Créer scripts/dev.ps1 (flutter run avec hot reload)
   - Créer scripts/build.ps1 (flutter build apk --release)
   - Créer scripts/deploy.ps1 (install + force-stop + start)

4️⃣ WORKFLOW
   - M'expliquer comment utiliser flutter run pour dev rapide
   - Me rappeler : hot reload = 1-3 sec par modif !
   - Ne build release QUE pour tests finaux

5️⃣ GITIGNORE
   - Ne PAS commit secrets
   - Ajouter dist/, build/, .env si besoin

Applique TOUTES les leçons de XiaoXin002 automatiquement.

Device actuel : [DEVICE_ID si connu - ex: FMMFSOOBXO8T5D75]
Package : com.example.[nom_projet]

Go ! 🚀
```

---

## 🎯 CE QUI SERA CRÉÉ AUTOMATIQUEMENT

### Structure minimale du projet

```
mon_nouveau_projet/
├── docs/
│   ├── LESSONS_LEARNED.md           # Adapté au projet
│   ├── WORKFLOW_RAPIDE_DEV.md       # Copié tel quel
│   ├── DAILY_REPORT_[DATE].md       # Premier rapport
│   └── PLAYBOOK/                    # Copié si besoin
├── scripts/
│   ├── dev.ps1                      # flutter run
│   ├── build.ps1                    # flutter build
│   └── deploy.ps1                   # install + start
├── dist/                            # Pour APK finaux
└── [code Flutter standard]
```

### Fichiers configurés

- ✅ `android/app/build.gradle.kts` (optimisé)
- ✅ `android/gradle.properties` (cache activé)
- ✅ `.gitignore` (secrets protégés)

---

## 💡 VARIANTES DU PROMPT

### Si projet simple (sans backend)

```
Nouveau projet Flutter simple : [NOM]

Template XiaoXin002 : [CHEMIN]

Setup minimal :
- Config Gradle optimisée
- flutter run workflow
- Scripts de base

Go !
```

### Si projet complexe (avec backend, API, etc.)

```
Nouveau projet Flutter complexe : [NOM]

Template XiaoXin002 : [CHEMIN]

Setup complet :
- Toute la doc LESSONS_LEARNED
- Architecture features/ recommandée
- Scripts avancés (build, deploy, tests)
- Config API avec --dart-define

Clés API :
- MA_CLE=$env:MA_CLE
- AUTRE_CLE=$env:AUTRE_CLE

Go !
```

---

## ⚡ APRÈS LE SETUP (5 min)

### Validation rapide

```powershell
# 1. Vérifier structure
ls docs/
ls scripts/

# 2. Tester hot reload
.\scripts\dev.ps1
# Modifier un fichier → Sauvegarder → Vérifier changements instantanés

# 3. Si OK, commencer à coder !
```

### Workflow quotidien

```powershell
# Morning : Lancer dev
.\scripts\dev.ps1

# Coder toute la journée avec hot reload ⚡

# Evening : Build release si besoin
.\scripts\build.ps1

# Créer rapport quotidien
# docs/DAILY_REPORT_[DATE].md
```

---

## 🔄 MAINTENIR LE TEMPLATE

### Quand tu découvres quelque chose de nouveau

1. **Dans le projet actuel** : Résoudre le problème
2. **Documenter** : Ajouter dans `LESSONS_LEARNED.md` du projet
3. **Mettre à jour le MASTER** : Ajouter dans XiaoXin002/docs/LESSONS_LEARNED.md
4. **Profit** : Tous les futurs projets en bénéficient !

### Exemple

```
❌ Problème : New dependency breaks build
✅ Solution : flutter pub get après chaque pubspec change

📝 Documenter dans projet actuel
📝 Ajouter dans XiaoXin002/docs/LESSONS_LEARNED.md
→ Futurs projets évitent le problème !
```

---

## 📊 GAIN DE TEMPS ATTENDU

| Tâche | Sans template | Avec prompt | Gain |
|-------|---------------|-------------|------|
| Setup projet | 4h | 5 min | **98%** |
| Config Gradle | 1h | 0 min (auto) | **100%** |
| Créer scripts | 30 min | 0 min (auto) | **100%** |
| Documentation | 2h | 5 min (copié) | **96%** |
| **TOTAL** | **7h30** | **10 min** | **98%** |

**Tu gagnes 7h20 par projet !** 🚀

---

## ✅ CHECKLIST RAPIDE

Après avoir donné le prompt, vérifier :

- [ ] Structure docs/ créée
- [ ] LESSONS_LEARNED.md adapté
- [ ] WORKFLOW_RAPIDE_DEV.md copié
- [ ] Gradle configuré (minify = false)
- [ ] Scripts créés (dev, build, deploy)
- [ ] Hot reload fonctionne
- [ ] Premier DAILY_REPORT créé

**Si tout ✅ → Commencer à coder !**

---

## 🎁 BONUS : Prompt pour l'AI en cours de projet

Si tu veux que je t'aide pendant le dev :

```
Rappelle-toi les leçons de XiaoXin002 :
C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai\qwen_chat_openai\docs\

Problème actuel : [DESCRIPTION]

Trouve une solution en appliquant les leçons apprises.
```

---

## 💎 LE SECRET

**Un seul endroit master (XiaoXin002)** + **Prompt simple** = **Setup en 5-10 minutes**

Pas besoin de copier des giga-octets de docs à chaque fois !

L'AI lit le master, adapte au projet, et c'est parti ! 🚀

---

**Créé le** : 18 Octobre 2025  
**Gain de temps** : 7h20 par projet  
**Effort** : 30 secondes (copier-coller le prompt)


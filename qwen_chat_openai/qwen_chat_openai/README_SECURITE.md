# 🚨 Alerte GitGuardian - Action Immédiate Requise

**Date**: 18 Octobre 2025  
**Gravité**: 🔴 CRITIQUE  
**Temps estimé**: 45 minutes

---

## 🔍 Qu'est-ce qui s'est passé ?

GitGuardian a détecté un **secret à haute entropie Base64** dans votre dépôt GitHub `sky1241/fck-translation-`.

**Cause probable** : Les **7 fichiers APK** dans votre dépôt contiennent :
- Des données binaires (haute entropie → déclenche l'alerte)
- **Potentiellement votre clé API OpenAI** si vous avez construit avec `--dart-define=OPENAI_API_KEY=sk-proj-...`

---

## ⚡ ACTIONS IMMÉDIATES (À FAIRE MAINTENANT)

### 1. **Régénérer votre clé API OpenAI** (5 min) ⏰

Même si vous n'êtes pas sûr, **régénérez par précaution** :

1. Ouvrez : https://platform.openai.com/api-keys
2. **Révoquez** la clé actuelle
3. **Générez** une nouvelle clé
4. Mettez à jour localement :
   ```powershell
   $env:OPENAI_API_KEY = "sk-proj-NOUVELLE_CLE"
   ```

### 2. **Retirer les APK du dépôt Git** (5 min)

J'ai créé un script automatique :

```powershell
cd "C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-"
.\security_cleanup.ps1
```

Ou manuellement :
```powershell
git rm --cached *.apk
git rm --cached dist/*.apk
git commit -m "security: Retirer les APK du dépôt"
git push origin main
```

### 3. **Reconstruire l'APK avec la nouvelle clé** (10 min)

```powershell
cd qwen_chat_openai

flutter build apk --release `
  --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY `
  --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions `
  --dart-define=OPENAI_MODEL=gpt-4o-mini
```

### 4. **Distribuer l'APK via GitHub Releases** (5 min)

**Ne plus jamais commit d'APK dans Git !**

Utilisez GitHub Releases à la place :
```powershell
gh release create v1.0.4 build/app/outputs/flutter-apk/app-release.apk `
  -t "Version 1.0.4" `
  -n "Mise à jour de sécurité"
```

Ta copine pourra télécharger depuis :  
👉 https://github.com/sky1241/fck-translation-/releases/latest

---

## 📁 Fichiers Créés

J'ai créé ces fichiers pour t'aider :

1. **`security_cleanup.ps1`** ⭐  
   Script automatique pour nettoyer le dépôt
   
2. **`SECURITY_RESPONSE.md`** (English)  
   Guide détaillé avec toutes les commandes
   
3. **`SECURITY_CHECKLIST.md`** (English)  
   Liste de vérification complète
   
4. **`.gitignore`**  
   Empêche les futurs commits d'APK et de secrets
   
5. **`tools/.secret_api_key.example`**  
   Template pour stocker ta clé localement de façon sécurisée

---

## 🛡️ Prévention Future

### ✅ À FAIRE (Best Practices)

1. **Clés API** : Toujours via variables d'environnement
   ```powershell
   $env:OPENAI_API_KEY = "sk-proj-..."  # Local uniquement
   ```

2. **Fichier secret local** :
   ```bash
   # Créer tools/.secret_api_key.txt (déjà dans .gitignore)
   echo "sk-proj-..." > tools/.secret_api_key.txt
   ```

3. **Build APK** : Ne pas inclure la clé
   ```bash
   # ✅ BON
   flutter build apk --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY
   
   # ❌ MAUVAIS (embedding direct)
   flutter build apk --dart-define=OPENAI_API_KEY=sk-proj-xxx
   ```

4. **Distribution APK** : GitHub Releases ou lien privé (pas Git)

### ❌ À NE JAMAIS FAIRE

- ❌ Committer des fichiers `.apk` dans Git
- ❌ Committer `.env` ou `.secret_api_key.txt`
- ❌ Hardcoder des clés API dans le code
- ❌ Partager des screenshots avec des clés visibles

---

## 🚀 Démarrage Rapide (Copier-Coller)

```powershell
# Navigation
cd "C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-"

# 1. Lancer le script de nettoyage automatique
.\security_cleanup.ps1

# 2. Régénérer la clé sur OpenAI (manuel)
Start-Process "https://platform.openai.com/api-keys"

# 3. Mettre à jour la variable d'environnement
$env:OPENAI_API_KEY = "sk-proj-NOUVELLE_CLE"

# 4. Reconstruire l'APK
cd qwen_chat_openai
flutter build apk --release `
  --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY `
  --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions `
  --dart-define=OPENAI_MODEL=gpt-4o-mini

# 5. Tester
adb install -r build/app/outputs/flutter-apk/app-release.apk

# 6. Créer une GitHub Release
gh release create v1.0.4 build/app/outputs/flutter-apk/app-release.apk `
  -t "Version 1.0.4 - Mise à jour sécurité" `
  -n "Rotation des clés API suite à alerte GitGuardian"
```

---

## ❓ Questions Fréquentes

### Q: Est-ce que ma clé API a été exposée ?

**Réponse** : Probablement si :
- Tu as build l'APK avec `--dart-define=OPENAI_API_KEY=sk-proj-...`
- L'APK a été commit dans Git
- → Quelqu'un qui clone le dépôt peut extraire la clé

**Action** : Régénère la clé par précaution (5 min)

### Q: Comment vérifier si l'APK contient ma clé ?

```powershell
# Installer apktool
# Download: https://apktool.org/

# Décompiler l'APK
apktool d XiaoXin002-v1.0.3.apk -o decompiled

# Chercher la clé
Select-String -Path "decompiled\*" -Pattern "sk-proj-" -Recurse
```

### Q: Faut-il supprimer l'historique Git ?

**Recommandé** : Oui, pour supprimer complètement les APK de l'historique :

```powershell
# Utiliser BFG Repo-Cleaner
# Download: https://rtyley.github.io/bfg-repo-cleaner/

git clone --mirror https://github.com/sky1241/fck-translation-.git
java -jar bfg.jar --delete-files "*.apk" fck-translation-.git
cd fck-translation-.git
git reflog expire --expire=now --all
git gc --prune=now --aggressive
git push --force
```

⚠️ **Attention** : `git push --force` réécrit l'historique !

### Q: Comment partager l'APK avec ma copine maintenant ?

**Option 1 (Recommandé)** : GitHub Releases
```powershell
gh release create v1.0.4 app-release.apk
# Lien : https://github.com/sky1241/fck-translation-/releases
```

**Option 2** : OneDrive/Google Drive
- Upload l'APK
- Partage le lien privé

**Option 3** : Serveur local (réseau local uniquement)

---

## 📊 Checklist de Vérification

- [ ] ✅ Clé API régénérée sur OpenAI
- [ ] ✅ Ancienne clé révoquée
- [ ] ✅ `$env:OPENAI_API_KEY` mis à jour
- [ ] ✅ APK retirés du dépôt Git (`git rm --cached`)
- [ ] ✅ `.gitignore` mis à jour
- [ ] ✅ Changements poussés (`git push`)
- [ ] ✅ APK reconstruit avec nouvelle clé
- [ ] ✅ APK testé (traduction + WebSocket)
- [ ] ✅ APK distribué via GitHub Release (pas Git)
- [ ] ✅ Logs OpenAI vérifiés (pas d'usage suspect)

---

## 🔗 Liens Utiles

- **OpenAI API Keys** : https://platform.openai.com/api-keys
- **GitGuardian Dashboard** : https://dashboard.gitguardian.com/
- **BFG Repo-Cleaner** : https://rtyley.github.io/bfg-repo-cleaner/
- **GitHub CLI (gh)** : https://cli.github.com/
- **Apktool** : https://apktool.org/

---

## 💡 Besoin d'Aide ?

Si tu bloques, ouvre un terminal et lance :
```powershell
cd "C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-"
.\security_cleanup.ps1 --DryRun  # Mode test (pas de changements)
```

Le script t'expliquera étape par étape ce qui doit être fait.

---

**Status** : 🔴 ACTION REQUISE  
**Priorité** : CRITIQUE  
**Temps estimé** : 45 minutes  
**Difficulté** : ⭐⭐ Moyenne

**Tu peux le faire ! 💪**


# 🚨 GitGuardian Alert - Response Plan

**Alert Date**: October 18, 2025 09:01 UTC  
**Repository**: sky1241/fck-translation-  
**Finding**: Base64 Generic High Entropy Secret

---

## 🔍 Root Cause Analysis

### **Likely Culprit: APK Files**

Found **7 APK files** committed to your repository:
- `XiaoXin002-v1.0.0.apk` (root)
- `XiaoXin002-v1.0.3.apk` (root)
- `dist/qwen-chat-openai-release.apk`
- `qwen_chat_openai/dist/*.apk` (multiple)

**Problem**: APK files contain compiled Flutter app with:
- ✅ Binary data (high entropy → triggers GitGuardian)
- ⚠️ Potentially embedded `--dart-define` values
- ⚠️ Build-time configuration that may include API keys

**If you built these APKs with**:
```bash
flutter build apk --dart-define=OPENAI_API_KEY=sk-proj-...
```

→ **The API key IS embedded in the APK file** (accessible via reverse engineering)

---

## ⚡ IMMEDIATE ACTION REQUIRED

### 1. **Rotate Your OpenAI API Key NOW** ⏰

Even if you're not sure if the key is in the APK, rotate it as a precaution:

```powershell
# 1. Go to OpenAI Dashboard
Start-Process "https://platform.openai.com/api-keys"

# 2. Revoke the current key
# 3. Generate a new key
# 4. Update your local environment

$env:OPENAI_API_KEY = "sk-proj-NEW_KEY_HERE"
```

### 2. **Remove APK Files from Git Repository**

**Option A: Remove from future commits** (keeps history):

```powershell
cd "C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-"

# Remove APK files from git tracking (but keep local files)
git rm --cached XiaoXin002-v1.0.0.apk
git rm --cached XiaoXin002-v1.0.3.apk
git rm --cached dist/*.apk
git rm --cached qwen_chat_openai/dist/*.apk

# Commit the removal
git commit -m "Remove APK files from repository"

# Push changes
git push origin main
```

**Option B: Purge from entire history** (recommended for secrets):

```powershell
# WARNING: This rewrites history and requires force push

# Install BFG Repo-Cleaner
# Download from: https://rtyley.github.io/bfg-repo-cleaner/

# Clone with full history
git clone --mirror https://github.com/sky1241/fck-translation-.git

# Remove all APK files from history
java -jar bfg.jar --delete-files "*.apk" fck-translation-.git

# Clean up
cd fck-translation-.git
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Force push (⚠️ requires --force)
git push --force
```

### 3. **Update .gitignore**

Already created `.gitignore` with:
```gitignore
dist/*.apk
*.apk
```

This prevents future APK commits.

### 4. **Check APK for Embedded Secrets**

To verify if your APK contains the API key:

```powershell
# Install apktool
# Download from: https://apktool.org/

# Decompile APK
apktool d XiaoXin002-v1.0.3.apk -o decompiled

# Search for API key pattern
Select-String -Path "decompiled\*" -Pattern "sk-proj-" -Recurse

# Or search in strings
Get-Content "decompiled\resources.arsc" | Select-String "sk-proj"
```

If found → **Your API key is public** → Must rotate immediately

---

## 🛡️ Secure Build Process

### **DO NOT** Include Keys in APK

**❌ WRONG (embeds key in APK)**:
```bash
flutter build apk --release --dart-define=OPENAI_API_KEY=sk-proj-xxx
```

**✅ CORRECT (use environment variables)**:
```bash
# Option 1: Read from environment at runtime
flutter build apk --release --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY

# Option 2: Use secrets manager (production)
flutter build apk --release --dart-define=OPENAI_API_KEY=PLACEHOLDER
# Then inject real key at runtime via secure storage
```

### **Better: Runtime Configuration**

Modify `lib/core/env/app_env.dart`:
```dart
import 'package:flutter_secure_storage/flutter_secure_storage';

class AppEnv {
  static final _storage = FlutterSecureStorage();
  
  // Don't embed key at build time
  static Future<String> getApiKey() async {
    // Load from secure storage (set by user on first launch)
    return await _storage.read(key: 'openai_api_key') ?? '';
  }
}
```

---

## 📦 Distribute APKs Securely

### **Instead of Committing APKs to Git:**

**Option 1: GitHub Releases**
```bash
# Create a release
gh release create v1.0.3 XiaoXin002-v1.0.3.apk -t "Version 1.0.3" -n "Release notes"

# Your girlfriend downloads from:
# https://github.com/sky1241/fck-translation-/releases/latest
```

**Option 2: Self-Hosted**
```bash
# Upload to OneDrive/Google Drive/Dropbox
# Share download link (not committed to git)
```

**Option 3: Build Server (Best)**
- Use GitHub Actions to build APK
- Store in GitHub Artifacts (private)
- Download via Actions workflow

---

## ✅ Verification Checklist

After cleanup:

- [ ] **Rotated OpenAI API key**
  - New key generated
  - Old key revoked
  - Local environment updated
  
- [ ] **Removed APK files from git**
  - `git rm --cached *.apk`
  - Or purged with BFG
  - Pushed changes
  
- [ ] **Verified .gitignore works**
  ```bash
  echo "test" > test.apk
  git status  # Should NOT show test.apk
  ```
  
- [ ] **Rebuilt app with new key**
  ```bash
  flutter build apk --release --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY
  ```
  
- [ ] **Tested app still works**
  - Translation works
  - WebSocket sync works
  
- [ ] **Distributed APK securely**
  - Via GitHub Release
  - Or private link (not in git)

---

## 📊 Impact Assessment

**If APK contains old key:**
- ⚠️ Anyone who cloned your repo can extract it
- ⚠️ GitGuardian scanned it
- ⚠️ Assume the key is compromised

**Remediation:**
1. ✅ Rotate key immediately
2. ✅ Remove APK from history
3. ✅ Monitor OpenAI usage for unauthorized activity
4. ✅ Rebuild with new key

**If APK does NOT contain key:**
- ✅ GitGuardian likely flagged binary data (false positive)
- ✅ Still remove APKs to avoid future issues
- ✅ Rotate key as precaution

---

## 🚀 Next Steps (Priority Order)

1. **NOW**: Rotate OpenAI API key (5 min)
2. **NOW**: Remove APK files from repository (5 min)
3. **TODAY**: Purge APKs from git history with BFG (15 min)
4. **TODAY**: Rebuild APK with new key (10 min)
5. **TODAY**: Test app with new key (5 min)
6. **TODAY**: Share new APK via GitHub Releases (5 min)

**Total Time**: 45 minutes

---

## 📞 Support Resources

- OpenAI API Keys: https://platform.openai.com/api-keys
- BFG Repo-Cleaner: https://rtyley.github.io/bfg-repo-cleaner/
- GitHub Releases: https://docs.github.com/en/repositories/releasing-projects-on-github
- GitGuardian Dashboard: https://dashboard.gitguardian.com/

---

**Status**: 🔴 IMMEDIATE ACTION REQUIRED  
**Priority**: CRITICAL  
**ETA**: 45 minutes

---

## 🔄 Quick Start Commands

```powershell
# 1. Navigate to project
cd "C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-"

# 2. Check if repo has git
git status

# 3. Remove APK files from tracking
git rm --cached *.apk
git rm --cached dist/*.apk
git rm --cached qwen_chat_openai/dist/*.apk
git rm --cached qwen_chat_openai/qwen_chat_openai/dist/*.apk

# 4. Commit removal
git commit -m "security: Remove APK files from repository"

# 5. Push changes
git push origin main

# 6. Rotate API key on OpenAI dashboard

# 7. Update local environment
$env:OPENAI_API_KEY = "sk-proj-NEW_KEY"

# 8. Rebuild APK
cd qwen_chat_openai
flutter build apk --release `
  --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY `
  --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions `
  --dart-define=OPENAI_MODEL=gpt-4o-mini

# 9. Test APK
adb install -r build/app/outputs/flutter-apk/app-release.apk

# 10. Create GitHub Release
gh release create v1.0.4 build/app/outputs/flutter-apk/app-release.apk `
  -t "Version 1.0.4 - Security Update" `
  -n "Security update: Rotated API keys"
```

---

**Remember**: Never commit APK files again! Use GitHub Releases or private links instead.


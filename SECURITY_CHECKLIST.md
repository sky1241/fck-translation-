# 🔒 Security Checklist - GitGuardian Alert Response

**Date**: October 18, 2025  
**Repository**: sky1241/fck-translation-  
**Alert**: Base64 Generic High Entropy Secret

---

## ✅ Immediate Actions

### 1. **Rotate ALL API Keys (Priority 1)**

Even if no keys were found, rotate as a precaution:

- [ ] **OpenAI API Key**
  - Go to: https://platform.openai.com/api-keys
  - Revoke the current key: `sk-proj-...`
  - Generate a new key
  - Update `$env:OPENAI_API_KEY` locally
  - **DO NOT commit the new key**

- [ ] **OpenAI Project ID**
  - Verify `proj_...` is not sensitive
  - If needed, rotate in OpenAI dashboard

### 2. **Check GitHub Repository**

- [ ] Visit: https://github.com/sky1241/fck-translation-
- [ ] Check the file pushed on Oct 18, 2025 at 09:01 UTC
- [ ] Look for GitGuardian's highlighted lines
- [ ] Common culprits:
  - Documentation files with example keys
  - PowerShell history or logs
  - Build output files
  - APK files with embedded config

### 3. **Remove Secrets from Git History**

If a secret was committed:

```powershell
# Install BFG Repo-Cleaner
# Download from: https://rtyley.github.io/bfg-repo-cleaner/

# Clone the repo with full history
git clone --mirror https://github.com/sky1241/fck-translation-.git

# Remove secrets (replace YOUR_SECRET_KEY)
bfg --replace-text passwords.txt fck-translation-.git

# Force push clean history
cd fck-translation-.git
git reflog expire --expire=now --all
git gc --prune=now --aggressive
git push --force
```

Or use GitHub's secret scanning removal:
- Settings → Security → Secret scanning alerts
- Follow GitHub's guided remediation

### 4. **Add Protection Files**

- [x] Create `.gitignore` (done)
- [ ] Create `.env.example` with placeholders
- [ ] Add pre-commit hook to scan for secrets

---

## 🛡️ Prevention Measures

### Never Commit These Files:

```
.secret_api_key.txt
.env
key.properties (with real passwords)
*.keystore
*.jks
android/local.properties
```

### Safe Practices:

1. **Environment Variables Only**
   ```powershell
   # Set locally (not committed)
   $env:OPENAI_API_KEY = "sk-..."
   ```

2. **Use --dart-define at Runtime**
   ```bash
   flutter run --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY
   ```

3. **Secret Files in `.gitignore`**
   - Store keys in `tools/.secret_api_key.txt`
   - Already in `.gitignore`

4. **GitHub Secrets for CI/CD**
   - Repository → Settings → Secrets → Actions
   - Add `OPENAI_API_KEY` as encrypted secret
   - Reference in `.github/workflows/flutter-ci.yml`

---

## 🔍 What GitGuardian Detected

**Possible Causes:**

1. **Documentation Examples**
   - Files like `PROMPT_NOUVELLE_SESSION.md` contain `$env:OPENAI_API_KEY # sk-proj-...`
   - These are **comments/placeholders**, not real keys
   - But GitGuardian flags them as potential secrets

2. **High-Entropy Strings**
   - Base64 encoded data (e.g., app icons, build artifacts)
   - Long random strings in docs
   - APK files in `dist/` folder

3. **Build Artifacts**
   - APK files may contain compiled config
   - Should not be committed (use GitHub Releases instead)

---

## ✅ Verification Steps

After rotating keys and cleaning history:

- [ ] Clone fresh repo: `git clone https://github.com/sky1241/fck-translation-.git`
- [ ] Search for secrets:
  ```powershell
  git log -S "sk-proj-" --all --pretty=format:"%H %s"
  git grep -E "sk-proj-[A-Za-z0-9_-]{64,}"
  ```
- [ ] Verify `.gitignore` is working:
  ```powershell
  echo "sk-test-key" > tools/.secret_api_key.txt
  git status  # Should NOT show the file
  ```
- [ ] Test app still works with new keys

---

## 📱 Current Safe Configuration

Your app correctly uses:

```dart
// lib/core/env/app_env.dart
static const String apiKey = String.fromEnvironment('OPENAI_API_KEY');
```

This is **secure** because:
- ✅ Key is passed at build time, not hardcoded
- ✅ Not stored in source code
- ✅ Not committed to git
- ✅ Only in environment variables

---

## 🚨 If You Find a Real Secret

**Assume it's compromised immediately:**

1. **Rotate the key NOW** (don't wait)
2. **Review OpenAI usage logs** for unauthorized activity
3. **Remove from git history** using BFG
4. **Force push** cleaned history
5. **Monitor for 48 hours** for suspicious API usage

---

## 📞 Resources

- OpenAI Dashboard: https://platform.openai.com/account/api-keys
- GitGuardian: https://dashboard.gitguardian.com/
- BFG Repo-Cleaner: https://rtyley.github.io/bfg-repo-cleaner/
- GitHub Secret Scanning: https://docs.github.com/en/code-security/secret-scanning

---

**Status**: 🟡 Pending verification  
**Next Step**: Check GitHub repo for the exact file GitGuardian flagged


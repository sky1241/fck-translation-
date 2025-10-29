# 🚀 Installation Rapide XiaoXin002

## Pour TESTER RAPIDEMENT (sans recompiler)

### 📱 Sur TÉLÉPHONE

```powershell
# Désinstaller l'ancienne version
adb -s FMMFSOOBXO8T5D75 uninstall com.example.qwen_chat_openai

# Installer l'APK RELEASE (déjà compilé)
adb -s FMMFSOOBXO8T5D75 install build\app\outputs\flutter-apk\app-release.apk

# Lancer
adb -s FMMFSOOBXO8T5D75 shell am start -n com.example.qwen_chat_openai/.MainActivity
```

### 🖥️ Sur ÉMULATEUR

```powershell
# Désinstaller l'ancienne version  
adb -s emulator-5554 uninstall com.example.qwen_chat_openai

# Installer l'APK RELEASE
adb -s emulator-5554 install build\app\outputs\flutter-apk\app-release.apk

# Lancer
adb -s emulator-5554 shell am start -n com.example.qwen_chat_openai/.MainActivity
```

---

## ✅ VÉRIFICATION RAPIDE

```powershell
# Voir les apps
adb devices

# Voir les logs émulateur
adb -s emulator-5554 logcat | Select-String "flutter|relay"

# Voir les logs téléphone
adb -s FMMFSOOBXO8T5D75 logcat | Select-String "flutter|relay"
```

---

## ⚡ PLUS DE CŒUR !

L'APK RELEASE dans `build\app\outputs\flutter-apk\app-release.apk` 

**N'A PAS** le bouton cœur.  
**N'A QUE** le bouton swap (↔️).

Si vous voyez encore le cœur = ancienne version en cache.  
Solution = Désinstaller puis réinstaller l'APK.



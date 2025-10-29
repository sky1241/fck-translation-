# ⚡ COMMANDES RAPIDES - XiaoXin002

## 🚀 Build et Deploy (Copier-Coller)

```powershell
# 1. Build (2-5 min)
cd "C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai\qwen_chat_openai"
flutter build apk --release --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY --dart-define=OPENAI_PROJECT=$env:OPENAI_PROJECT --dart-define=OPENAI_MODEL=gpt-4o-mini --dart-define=RELAY_WS_URL=wss://fck-relay-ws.onrender.com --dart-define=RELAY_ROOM=demo123

# 2. Vérifier appareils
adb devices

# Si offline :
adb kill-server && adb start-server && adb devices

# 3. Installer sur les DEUX
adb -s FMMFSOOBXO8T5D75 install -r build\app\outputs\flutter-apk\app-release.apk
adb -s emulator-5554 install -r build\app\outputs\flutter-apk\app-release.apk

# 4. Force-stop (OBLIGATOIRE!)
adb -s FMMFSOOBXO8T5D75 shell am force-stop com.example.qwen_chat_openai
adb -s emulator-5554 shell am force-stop com.example.qwen_chat_openai

# 5. Lancer
adb -s FMMFSOOBXO8T5D75 shell am start -n com.example.qwen_chat_openai/.MainActivity
adb -s emulator-5554 shell am start -n com.example.qwen_chat_openai/.MainActivity

# 6. FINAL : Copier APK pour copine (après validation!)
copy build\app\outputs\flutter-apk\app-release.apk dist\XiaoXin002-latest.apk
```

## 📱 Appareils

- **Téléphone** : `FMMFSOOBXO8T5D75`
- **Émulateur** : `emulator-5554`
- **Package** : `com.example.qwen_chat_openai`

## ⚠️ À NE PAS OUBLIER

1. **Force-stop** après install (sinon ancien code!)
2. **PAS de flutter clean** sauf si nécessaire (perd 85 min)
3. **Tester AVANT** de copier dans dist/ pour copine
4. **Vérifier** que toutes les modifs sont bien dans l'APK

## 🔍 Logs

```powershell
# Nettoyer et surveiller
adb -s FMMFSOOBXO8T5D75 logcat -c
adb -s FMMFSOOBXO8T5D75 logcat | Select-String "flutter|qwen|relay|Badge"

# Chercher dans historique
adb -s FMMFSOOBXO8T5D75 logcat -d | Select-String "relay.*in" | Select-Object -Last 10
```

## 📂 Fichiers Importants

- `lib/features/chat/presentation/chat_page.dart` - UI
- `lib/features/chat/presentation/chat_controller.dart` - Logique
- `lib/features/chat/data/translation_service.dart` - Traduction
- `lib/core/network/badge_service.dart` - Badge compteur

## 📝 Prompt Complet

Voir : `docs/COPIER_CE_PROMPT.txt`


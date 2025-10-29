## Lancer en mode réel (Android Studio Copilot)

Pré‑requis: variables d’environnement `OPENAI_API_KEY` et `OPENAI_PROJECT`. Les URLs stables Render sont déjà intégrées par défaut.

### Téléphone (réel)
```powershell
cd "C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai"
flutter run -d FMMFSOOBXO8T5D75 --no-resident `
  --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY `
  --dart-define=OPENAI_PROJECT=$env:OPENAI_PROJECT `
  --dart-define=OPENAI_MODEL=gpt-4o-mini `
  --dart-define=RELAY_ROOM=demo123
```

### Émulateur API 30
```powershell
$emu=(adb devices | Select-String "^emulator-" | % { ($_ -split "\s+")[0] } | Select-Object -First 1)
cd "C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai"
flutter run -d $emu --device-timeout 180 --no-resident `
  --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY `
  --dart-define=OPENAI_PROJECT=$env:OPENAI_PROJECT `
  --dart-define=OPENAI_MODEL=gpt-4o-mini `
  --dart-define=RELAY_ROOM=demo123
```

### Notes
- Pas besoin de tunnel local: proxy et relay Render sont permanents.
- Même `RELAY_ROOM` sur les deux appareils.
- L’AVD API 30 est recommandé (désactiver Wellbeing/QuickSearchBox, animations à 0).


$ErrorActionPreference="Stop"
$proj="C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai"
cd $proj
$avd="ChatAPI30Lite"; flutter emulators --launch $avd | Out-Null; Start-Sleep 10
$emu=(adb devices | Select-String "^emulator-" | % { ($_ -split "\s+")[0] } | Select-Object -First 1)
flutter run -d $emu --release --device-timeout 180 --no-resident `
  --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions `
  --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY `
  --dart-define=OPENAI_PROJECT=$env:OPENAI_PROJECT `
  --dart-define=OPENAI_MODEL=gpt-4o-mini `
  --dart-define=RELAY_WS_URL=wss://fck-relay-ws.onrender.com `
  --dart-define=RELAY_ROOM=test123


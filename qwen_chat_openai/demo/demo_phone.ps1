$ErrorActionPreference="Stop"
$proj="C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai"
cd $proj
flutter run -d FMMFSOOBXO8T5D75 --release --no-resident `
  --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions `
  --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY `
  --dart-define=OPENAI_PROJECT=$env:OPENAI_PROJECT `
  --dart-define=OPENAI_MODEL=gpt-4o-mini `
  --dart-define=RELAY_WS_URL=wss://fck-relay-ws.onrender.com `
  --dart-define=RELAY_ROOM=test123


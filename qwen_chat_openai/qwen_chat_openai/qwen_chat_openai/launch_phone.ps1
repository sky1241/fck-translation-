$ErrorActionPreference="Stop"

Write-Host "📱 Lancement de l'application sur le TÉLÉPHONE..." -ForegroundColor Cyan
Write-Host "Direction: ZH → FR (Chinois vers Français)" -ForegroundColor Yellow
Write-Host ""

$proj = "C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai\qwen_chat_openai"
cd $proj

# Vérifier que le téléphone est connecté
$phone = "FMMFSOOBXO8T5D75"
$connected = (adb devices | Select-String $phone)

if (-not $connected) {
    Write-Host "❌ Téléphone non détecté ($phone). Veuillez le connecter via USB." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Téléphone détecté: $phone" -ForegroundColor Green
Write-Host ""

# Lancer l'application avec les bonnes configurations
Write-Host "📦 Build et installation en cours..." -ForegroundColor Cyan

flutter run -d $phone --release `
  --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions `
  --dart-define="OPENAI_API_KEY=$env:OPENAI_API_KEY" `
  --dart-define="OPENAI_PROJECT=$env:OPENAI_PROJECT" `
  --dart-define=OPENAI_MODEL=gpt-4o-mini `
  --dart-define=RELAY_WS_URL=wss://fck-relay-ws.onrender.com `
  --dart-define=RELAY_ROOM=test123 `
  --dart-define=CHAT_DEFAULT_DIRECTION=zh2fr

Write-Host ""
Write-Host "✅ Application lancée sur le téléphone !" -ForegroundColor Green


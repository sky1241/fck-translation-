$ErrorActionPreference="Stop"

Write-Host "🚀 Lancement de l'application sur l'ÉMULATEUR..." -ForegroundColor Cyan
Write-Host "Direction: FR → ZH (Français vers Chinois)" -ForegroundColor Yellow
Write-Host ""

$proj = "C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai\qwen_chat_openai"
cd $proj

# Vérifier que l'émulateur est lancé
$emu = (adb devices | Select-String "^emulator-" | ForEach-Object { ($_ -split "\s+")[0] } | Select-Object -First 1)

if (-not $emu) {
    Write-Host "❌ Aucun émulateur détecté. Veuillez lancer l'émulateur d'abord." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Émulateur détecté: $emu" -ForegroundColor Green
Write-Host ""

# Lancer l'application avec les bonnes configurations
Write-Host "📦 Build et installation en cours..." -ForegroundColor Cyan

flutter run -d $emu --release --device-timeout 180 `
  --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions `
  --dart-define="OPENAI_API_KEY=$env:OPENAI_API_KEY" `
  --dart-define="OPENAI_PROJECT=$env:OPENAI_PROJECT" `
  --dart-define=OPENAI_MODEL=gpt-4o-mini `
  --dart-define=RELAY_WS_URL=wss://fck-relay-ws.onrender.com `
  --dart-define=RELAY_ROOM=test123 `
  --dart-define=CHAT_DEFAULT_DIRECTION=fr2zh

Write-Host ""
Write-Host "✅ Application lancée sur l'émulateur !" -ForegroundColor Green


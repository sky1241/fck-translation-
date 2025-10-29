$ErrorActionPreference="Stop"

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  NETTOYAGE ET LANCEMENT DES DEUX APPS" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

$proj = "C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai\qwen_chat_openai"
cd $proj

# 1. Vérifier les appareils
Write-Host "📱 Vérification des appareils..." -ForegroundColor Yellow
$devices = adb devices | Select-String "device$" | Where-Object { $_ -notmatch "List of" }
Write-Host $devices
Write-Host ""

$emu = (adb devices | Select-String "^emulator-" | ForEach-Object { ($_ -split "\s+")[0] } | Select-Object -First 1)
$phone = "FMMFSOOBXO8T5D75"

if (-not $emu) {
    Write-Host "❌ Émulateur non détecté. Lancez-le d'abord avec:" -ForegroundColor Red
    Write-Host "   flutter emulators --launch ChatAPI30Lite" -ForegroundColor Yellow
    exit 1
}

$phoneConnected = (adb devices | Select-String $phone)
if (-not $phoneConnected) {
    Write-Host "⚠️  Téléphone non détecté ($phone). Seul l'émulateur sera configuré." -ForegroundColor Yellow
    $phone = $null
}

Write-Host "✅ Émulateur: $emu" -ForegroundColor Green
if ($phone) {
    Write-Host "✅ Téléphone: $phone" -ForegroundColor Green
}
Write-Host ""

# 2. Désinstaller les anciennes versions
Write-Host "🗑️  Désinstallation des anciennes versions..." -ForegroundColor Yellow
adb -s $emu uninstall com.example.qwen_chat_openai 2>$null
if ($phone) {
    adb -s $phone uninstall com.example.qwen_chat_openai 2>$null
}
Write-Host "✅ Désinstallation terminée" -ForegroundColor Green
Write-Host ""

# 3. Nettoyer le build
Write-Host "🧹 Nettoyage du build..." -ForegroundColor Yellow
flutter clean | Out-Null
Write-Host "✅ Nettoyage terminé" -ForegroundColor Green
Write-Host ""

# 4. Réinstaller les dépendances
Write-Host "📦 Réinstallation des dépendances..." -ForegroundColor Yellow
flutter pub get
Write-Host "✅ Dépendances installées" -ForegroundColor Green
Write-Host ""

# 5. Build pour l'émulateur (FR→ZH) en DEBUG
Write-Host "🏗️  BUILD ÉMULATEUR (FR→ZH) en mode DEBUG..." -ForegroundColor Cyan
Write-Host ""

flutter build apk --debug `
  --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions `
  --dart-define="OPENAI_API_KEY=$env:OPENAI_API_KEY" `
  --dart-define="OPENAI_PROJECT=$env:OPENAI_PROJECT" `
  --dart-define=OPENAI_MODEL=gpt-4o-mini `
  --dart-define=RELAY_WS_URL=wss://fck-relay-ws.onrender.com `
  --dart-define=RELAY_ROOM=test123 `
  --dart-define=CHAT_DEFAULT_DIRECTION=fr2zh

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build émulateur échoué" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ Build émulateur réussi !" -ForegroundColor Green
Write-Host ""

# 6. Installer sur l'émulateur
Write-Host "📲 Installation sur l'émulateur..." -ForegroundColor Yellow
adb -s $emu install build\app\outputs\flutter-apk\app-debug.apk
Write-Host "✅ Installation émulateur terminée" -ForegroundColor Green
Write-Host ""

# 7. Build pour le téléphone (ZH→FR) si connecté
if ($phone) {
    Write-Host "🏗️  BUILD TÉLÉPHONE (ZH→FR) en mode DEBUG..." -ForegroundColor Cyan
    Write-Host ""
    
    flutter build apk --debug `
      --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions `
      --dart-define="OPENAI_API_KEY=$env:OPENAI_API_KEY" `
      --dart-define="OPENAI_PROJECT=$env:OPENAI_PROJECT" `
      --dart-define=OPENAI_MODEL=gpt-4o-mini `
      --dart-define=RELAY_WS_URL=wss://fck-relay-ws.onrender.com `
      --dart-define=RELAY_ROOM=test123 `
      --dart-define=CHAT_DEFAULT_DIRECTION=zh2fr

    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Build téléphone échoué" -ForegroundColor Red
        exit 1
    }

    Write-Host ""
    Write-Host "✅ Build téléphone réussi !" -ForegroundColor Green
    Write-Host ""

    # 8. Installer sur le téléphone
    Write-Host "📲 Installation sur le téléphone..." -ForegroundColor Yellow
    adb -s $phone install build\app\outputs\flutter-apk\app-debug.apk
    Write-Host "✅ Installation téléphone terminée" -ForegroundColor Green
    Write-Host ""
}

# 9. Lancer les applications
Write-Host "🚀 Lancement des applications..." -ForegroundColor Cyan
adb -s $emu shell am start -n com.example.qwen_chat_openai/.MainActivity
if ($phone) {
    Start-Sleep -Seconds 2
    adb -s $phone shell am start -n com.example.qwen_chat_openai/.MainActivity
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "  ✅ TOUT EST PRÊT !" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""
Write-Host "📱 ÉMULATEUR (FR→ZH) : Tapez en français" -ForegroundColor Yellow
if ($phone) {
    Write-Host "📱 TÉLÉPHONE (ZH→FR) : Tapez en chinois" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "🔗 Les deux appareils sont connectés à:" -ForegroundColor Cyan
Write-Host "   - Relay: wss://fck-relay-ws.onrender.com" -ForegroundColor White
Write-Host "   - Room: test123" -ForegroundColor White
Write-Host ""
Write-Host "💬 Testez en envoyant un message depuis chaque appareil !" -ForegroundColor Green
Write-Host ""

# 10. Afficher les logs en temps réel
Write-Host "📊 Logs de l'émulateur (Ctrl+C pour quitter):" -ForegroundColor Cyan
adb -s $emu logcat | Select-String "flutter|relay"


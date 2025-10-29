#!/usr/bin/env pwsh
# Script de rebuild avec le nouveau badge de notification (comme WhatsApp)
# Date: 16 Octobre 2025

Write-Host "🔴 Rebuild de l'application avec badge de notification..." -ForegroundColor Cyan

# Nettoyer les anciens builds
Write-Host "🧹 Nettoyage..." -ForegroundColor Yellow
flutter clean

# Récupérer les dépendances
Write-Host "📦 Installation des packages (flutter_app_badger)..." -ForegroundColor Yellow
flutter pub get

# Build APK de debug
Write-Host "🔨 Build APK Debug..." -ForegroundColor Yellow
flutter build apk --debug

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build réussi!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📍 APK disponible à:" -ForegroundColor Cyan
    Write-Host "   build\app\outputs\flutter-apk\app-debug.apk" -ForegroundColor White
    Write-Host ""
    Write-Host "🔴 Le badge de notification est maintenant activé!" -ForegroundColor Green
    Write-Host "   • Quand vous recevez un message → Point rouge avec chiffre" -ForegroundColor White
    Write-Host "   • Quand vous ouvrez le chat → Badge effacé" -ForegroundColor White
    Write-Host ""
    Write-Host "📱 Pour tester:" -ForegroundColor Cyan
    Write-Host "   1. Installer l'APK sur votre téléphone" -ForegroundColor White
    Write-Host "   2. Envoyer un message via le relay WebSocket" -ForegroundColor White
    Write-Host "   3. Minimiser l'app (ne pas la fermer)" -ForegroundColor White
    Write-Host "   4. Observer le badge rouge sur l'icône 🔴" -ForegroundColor White
    Write-Host ""
    Write-Host "⚠️  Note: Le badge ne fonctionne que sur certains launchers Android" -ForegroundColor Yellow
    Write-Host "   (Samsung, Xiaomi, OnePlus, Google Pixel...)" -ForegroundColor Yellow
} else {
    Write-Host "❌ Erreur lors du build" -ForegroundColor Red
    exit 1
}



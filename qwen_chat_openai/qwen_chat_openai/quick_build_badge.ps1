#!/usr/bin/env pwsh
# Build RAPIDE avec badge (2-3 minutes au lieu de 90!)
# Date: 16 Octobre 2025

Write-Host "⚡ BUILD RAPIDE avec badge de notification..." -ForegroundColor Cyan
Write-Host "   (Sans flutter clean = Réutilise le cache existant)" -ForegroundColor Yellow
Write-Host ""

# Juste récupérer le nouveau package (flutter_app_badger)
Write-Host "📦 Ajout du package flutter_app_badger..." -ForegroundColor Yellow
flutter pub get

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erreur lors de flutter pub get" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🔨 Build APK DEBUG (build incrémental - rapide!)..." -ForegroundColor Yellow
$startTime = Get-Date

flutter build apk --debug

$endTime = Get-Date
$duration = ($endTime - $startTime).TotalSeconds

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Build réussi en $([math]::Round($duration, 0)) secondes!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📍 APK disponible à:" -ForegroundColor Cyan
    Write-Host "   build\app\outputs\flutter-apk\app-debug.apk" -ForegroundColor White
    Write-Host ""
    Write-Host "📱 Transférez l'APK sur votre téléphone et installez-le" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🔴 Le badge rouge est maintenant activé!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Gain de temps: ~90 minutes au lieu de ~3 minutes!" -ForegroundColor Magenta
} else {
    Write-Host "❌ Erreur lors du build" -ForegroundColor Red
    exit 1
}


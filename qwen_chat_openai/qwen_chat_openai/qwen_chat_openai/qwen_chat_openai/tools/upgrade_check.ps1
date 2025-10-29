$ErrorActionPreference='Stop'
Write-Host "Running flutter pub outdated..." -ForegroundColor Cyan
flutter pub outdated
Write-Host "Running analyzer..." -ForegroundColor Cyan
flutter analyze
Write-Host "OK. Review 'Resolvable Latest' column and analyzer output before bumping majors." -ForegroundColor Green



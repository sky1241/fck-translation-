# Requires: PowerShell 7+
# Usage examples:
#   1) Place your key in tools/.secret_api_key.txt, then run with defaults:
#      pwsh -File tools/run_two_instances.ps1 -BaseUrl "https://api.openai.com/v1/chat/completions" -EmulatorAvd "Pixel_6a_Android13"
#   2) Or pass the key inline (less secure):
#      pwsh -File tools/run_two_instances.ps1 -ApiKey "sk-..." -BaseUrl "https://api.openai.com/v1/chat/completions" -PhoneId "R58N..."

param(
  [string]$ApiKey,
  [string]$BaseUrl = "https://api.openai.com/v1/chat/completions",
  [string]$Model = "gpt-4o-mini",
  [string]$Tone = "casual",
  [bool]$PinyinEmu = $true,
  [bool]$PinyinPhone = $false,
  [string]$EmuDirection = "fr2zh",
  [string]$PhoneDirection = "zh2fr",
  [string]$PhoneId,
  [string]$EmulatorAvd,
  [switch]$SkipStartEmu,
  [int]$RelayPort = 8765,
  [switch]$StartRelay
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Read-SecretApiKeyFromFile {
  $secretPath = Join-Path $PSScriptRoot ".secret_api_key.txt"
  if (Test-Path -LiteralPath $secretPath) {
    $key = Get-Content -LiteralPath $secretPath -Raw | ForEach-Object { $_.Trim() }
    if (![string]::IsNullOrWhiteSpace($key)) { return $key }
  }
  return $null
}

function Read-ApiKeyFromEnv {
  if ($env:OPENAI_API_KEY -and -not [string]::IsNullOrWhiteSpace($env:OPENAI_API_KEY)) {
    return $env:OPENAI_API_KEY.Trim()
  }
  return $null
}

function Ensure-FlutterAvailable {
  try {
    $version = flutter --version
    Write-Host "Flutter found: $version" -ForegroundColor Green
  } catch {
    throw "Flutter CLI introuvable dans le PATH. Ouvrez un terminal Flutter ou installez Flutter."
  }
}

function Ensure-AdbAvailable {
  try {
    $ver = adb version
    Write-Host "ADB found: $ver" -ForegroundColor Green
  } catch {
    throw "ADB introuvable. Assurez-vous que le SDK Android est installé et que platform-tools est dans le PATH."
  }
}

function Start-EmulatorIfNeeded {
  param([string]$AvdName)
  if ($SkipStartEmu) { return }
  # Try to auto-pick an AVD if none provided
  if ([string]::IsNullOrWhiteSpace($AvdName)) {
    $emuExe1 = if ($env:ANDROID_HOME -and -not [string]::IsNullOrWhiteSpace($env:ANDROID_HOME)) { Join-Path $env:ANDROID_HOME "emulator\emulator.exe" } else { $null }
    $emuExe2 = if ($env:ANDROID_SDK_ROOT -and -not [string]::IsNullOrWhiteSpace($env:ANDROID_SDK_ROOT)) { Join-Path $env:ANDROID_SDK_ROOT "emulator\emulator.exe" } else { $null }
    $emuExeAuto = if (Test-Path $emuExe1) { $emuExe1 } elseif (Test-Path $emuExe2) { $emuExe2 } else { $null }
    if ($emuExeAuto) {
      try {
        $avds = & $emuExeAuto -list-avds 2>$null
        if ($avds) {
          $first = $avds | Select-Object -First 1
          if ($first) { $AvdName = $first.Trim() }
        }
      } catch { }
    }
  }
  if ([string]::IsNullOrWhiteSpace($AvdName)) { return }
  # If no running emulator, start one
  $devices = adb devices | Select-String 'emulator-\d+\s+device'
  if ($devices) { return }

  $emuExe1 = if ($env:ANDROID_HOME -and -not [string]::IsNullOrWhiteSpace($env:ANDROID_HOME)) { Join-Path $env:ANDROID_HOME "emulator\emulator.exe" } else { $null }
  $emuExe2 = if ($env:ANDROID_SDK_ROOT -and -not [string]::IsNullOrWhiteSpace($env:ANDROID_SDK_ROOT)) { Join-Path $env:ANDROID_SDK_ROOT "emulator\emulator.exe" } else { $null }
  $emuExe = if (Test-Path $emuExe1) { $emuExe1 } elseif (Test-Path $emuExe2) { $emuExe2 } else { $null }
  if (-not $emuExe) { throw "Emulator introuvable. Vérifiez ANDROID_HOME ou ANDROID_SDK_ROOT." }

  Write-Host "Démarrage de l'émulateur $AvdName..." -ForegroundColor Cyan
  Start-Process -FilePath $emuExe -ArgumentList @("-avd", $AvdName) | Out-Null

  # Wait until emulator appears
  $sw = [System.Diagnostics.Stopwatch]::StartNew()
  while ($sw.Elapsed.TotalMinutes -lt 4) {
    Start-Sleep -Seconds 3
    $emu = adb devices | Select-String 'emulator-\d+\s+device'
    if ($emu) { break }
    Write-Host "Attente de l'émulateur..." -ForegroundColor DarkGray
  }
}

function Start-RelayIfFree {
  param([int]$Port)
  try {
    $tcp = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction Stop
    if ($tcp) { return }
  } catch {}
  Write-Host "Démarrage du relay WebSocket sur le port $Port..." -ForegroundColor Cyan
  Start-Process pwsh -ArgumentList "-NoProfile","-Command","cd tools; python relay_server.py" | Out-Null
}

function Get-DeviceIds {
  # Returns a hashtable @{ Emu = 'emulator-5554'; Phone = 'R5...' }
  $lines = adb devices | Select-Object -Skip 1
  $emu = $null
  $phone = $null
  foreach ($l in $lines) {
    $t = $l.ToString().Trim()
    if ([string]::IsNullOrWhiteSpace($t)) { continue }
    if ($t -match "^(emulator-\d+)\s+device") { $emu = $Matches[1]; continue }
    if ($t -match "^([\w:-]+)\s+device") { $cand = $Matches[1]; if (-not ($cand -like 'emulator-*')) { $phone = $cand } }
  }
  return @{ Emu = $emu; Phone = $phone }
}

function Build-Defines {
  param(
    [string]$Direction,
    [bool]$Pinyin,
    [string]$ApiKeyValue,
    [string]$BaseUrlValue,
    [string]$ModelValue,
    [string]$ToneValue
  )
  $defines = @(
    "--dart-define=OPENAI_BASE_URL=$BaseUrlValue",
    "--dart-define=OPENAI_API_KEY=$ApiKeyValue",
    "--dart-define=OPENAI_MODEL=$ModelValue",
    "--dart-define=CHAT_DEFAULT_DIRECTION=$Direction",
    "--dart-define=CHAT_DEFAULT_TONE=$ToneValue",
    "--dart-define=CHAT_DEFAULT_PINYIN=$Pinyin"
  )
  return $defines
}

# 1) Resolve API key
if ([string]::IsNullOrWhiteSpace($ApiKey)) { $ApiKey = Read-SecretApiKeyFromFile }
if ([string]::IsNullOrWhiteSpace($ApiKey)) { $ApiKey = Read-ApiKeyFromEnv }
if ([string]::IsNullOrWhiteSpace($ApiKey)) { throw "Aucune clé API fournie. Passez -ApiKey, créez tools/.secret_api_key.txt, ou renseignez OPENAI_API_KEY." }

# 2) Check tools
Ensure-FlutterAvailable
Ensure-AdbAvailable

# 3) Optionally start emulator
Start-EmulatorIfNeeded -AvdName $EmulatorAvd

# 4) Start relay if requested
if ($StartRelay) { Start-RelayIfFree -Port $RelayPort }

# 5) Detect devices
$ids = Get-DeviceIds
$emuId = $ids.Emu
$phId = if ($PhoneId) { $PhoneId } else { $ids.Phone }
if (-not $emuId) { Write-Warning "Aucun émulateur détecté." }
if (-not $phId) { Write-Warning "Aucun téléphone détecté (USB)." }
if (-not $emuId -and -not $phId) { throw "Aucun device prêt. Branchez le téléphone et/ou lancez un AVD." }

# 6) Restore packages
Write-Host "flutter pub get..." -ForegroundColor Cyan
flutter pub get | Write-Host

# 7) Prepare command lines
$emuDefines = Build-Defines -Direction $EmuDirection -Pinyin $PinyinEmu -ApiKeyValue $ApiKey -BaseUrlValue $BaseUrl -ModelValue $Model -ToneValue $Tone
$phDefines  = Build-Defines -Direction $PhoneDirection -Pinyin $PinyinPhone -ApiKeyValue $ApiKey -BaseUrlValue $BaseUrl -ModelValue $Model -ToneValue $Tone

if ($emuId) {
  $emuArgs = @("-NoProfile","-Command","flutter run -d $emuId $($emuDefines -join ' ')")
  Write-Host "Lancement instance ÉMULATEUR ($emuId): FR→ZH" -ForegroundColor Green
  Start-Process pwsh -ArgumentList $emuArgs | Out-Null
}
if ($phId) {
  # Map relay port to phone and use localhost
  try { adb -s $phId reverse tcp:$RelayPort tcp:$RelayPort | Out-Null } catch {}
  $phDefines += @("--dart-define=RELAY_WS_URL=ws://127.0.0.1:$RelayPort","--dart-define=RELAY_ROOM=demo123")
  $phArgs = @("-NoProfile","-Command","flutter run -d $phId $($phDefines -join ' ')")
  Write-Host "Lancement instance TÉLÉPHONE ($phId): ZH→FR" -ForegroundColor Green
  Start-Process pwsh -ArgumentList $phArgs | Out-Null
}

Write-Host "Deux fenêtres devraient s'ouvrir avec flutter run (une par device)." -ForegroundColor Yellow
Write-Host "Note: les --dart-define exposent la clé dans la ligne de commande localement; évitez de partager des captures d'écran." -ForegroundColor DarkYellow



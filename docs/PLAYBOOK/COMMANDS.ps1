#!/usr/bin/env pwsh
#requires -Version 7.0
[CmdletBinding()]
param(
  [ValidateSet('phone','emu','both','health')]
  [string]$target = 'both',
  [switch]$UseLocalRelay,
  [switch]$DirectOpenAI
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$proj = "C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai"
Set-Location -LiteralPath $proj

# Fixed demo values (Chine OK via proxy Render)
$OPENAI_URL = 'https://fck-openai-proxy.onrender.com/v1/chat/completions'
$RELAY_URL  = 'wss://fck-relay-ws.onrender.com'
$ROOM       = 'test123'

function Initialize-AndroidSdkPath {
  [CmdletBinding(SupportsShouldProcess = $false)]
  param()
  $sdk = $env:ANDROID_SDK_ROOT
  if ([string]::IsNullOrWhiteSpace($sdk)) {
    $sdk = 'C:\Users\ludov\AppData\Local\Android\sdk'
  }
  $adbDir = Join-Path -Path $sdk -ChildPath 'platform-tools'
  $adbExe = Join-Path -Path $adbDir -ChildPath 'adb.exe'
  if (-not (Test-Path -LiteralPath $adbExe)) {
    throw "ADB not found at $adbExe. Install Android SDK Platform-Tools."
  }
  if (-not $env:ANDROID_SDK_ROOT) { $env:ANDROID_SDK_ROOT = $sdk }
  if (-not $env:ANDROID_HOME)     { $env:ANDROID_HOME     = $sdk }
  $paths = $env:Path -split ';'
  if (-not ($paths -contains $adbDir)) { $env:Path = "$($env:Path);$adbDir" }
  return $adbExe
}

function Start-PhoneRelease {
  [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
  param()
  if ([string]::IsNullOrWhiteSpace($env:OPENAI_API_KEY) -or [string]::IsNullOrWhiteSpace($env:OPENAI_PROJECT)) {
    throw 'Env vars OPENAI_API_KEY and OPENAI_PROJECT must be set.'
  }
  if ($DirectOpenAI) { $script:OPENAI_URL = 'https://api.openai.com/v1/chat/completions' }
  $relayForPhone = $RELAY_URL
  if ($UseLocalRelay) { $relayForPhone = 'ws://10.0.2.2:8765' }
  $flutterArgs = @(
    'run','-d','FMMFSOOBXO8T5D75','--release','--no-resident',
    "--dart-define=OPENAI_BASE_URL=$OPENAI_URL",
    "--dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY",
    "--dart-define=OPENAI_PROJECT=$env:OPENAI_PROJECT",
    "--dart-define=OPENAI_MODEL=gpt-4o-mini",
    "--dart-define=RELAY_WS_URL=$relayForPhone",
    "--dart-define=RELAY_ROOM=$ROOM"
  )
  $whatIfMessage = "Run release build on device FMMFSOOBXO8T5D75"
  if ($PSCmdlet.ShouldProcess('Flutter', $whatIfMessage, "Target: Android device FMMFSOOBXO8T5D75")) { & flutter @flutterArgs }
}

function Start-EmulatorRelease {
  [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
  param()
  if ([string]::IsNullOrWhiteSpace($env:OPENAI_API_KEY) -or [string]::IsNullOrWhiteSpace($env:OPENAI_PROJECT)) {
    throw 'Env vars OPENAI_API_KEY and OPENAI_PROJECT must be set.'
  }
  $adb = Initialize-AndroidSdkPath
  if ($DirectOpenAI) { $script:OPENAI_URL = 'https://api.openai.com/v1/chat/completions' }
  $avd = 'ChatAPI30Lite'
  if ($PSCmdlet.ShouldProcess('Flutter', "Launch emulator $avd", "Target: $avd")) {
    flutter emulators --launch $avd | Out-Null
    Start-Sleep 10
  }
  $emu = (& $adb devices | Select-String '^emulator-' | ForEach-Object { ($_ -split '\s+')[0] } | Select-Object -First 1)
  if (-not $emu) { throw 'No emulator detected.' }
  $relayForEmu = $RELAY_URL
  if ($UseLocalRelay) { $relayForEmu = 'ws://10.0.2.2:8765' }
  $flutterArgs = @(
    'run','-d',$emu,'--release','--device-timeout','180','--no-resident',
    "--dart-define=OPENAI_BASE_URL=$OPENAI_URL",
    "--dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY",
    "--dart-define=OPENAI_PROJECT=$env:OPENAI_PROJECT",
    "--dart-define=OPENAI_MODEL=gpt-4o-mini",
    "--dart-define=RELAY_WS_URL=$relayForEmu",
    "--dart-define=RELAY_ROOM=$ROOM"
  )
  $whatIfMessage = "Run release build on emulator $emu"
  if ($PSCmdlet.ShouldProcess('Flutter', $whatIfMessage, "Target: $emu")) { & flutter @flutterArgs }
}

function Test-Keepalive {
  (Invoke-WebRequest -Uri 'https://fck-openai-proxy.onrender.com/health').Content
  (Invoke-WebRequest -Uri 'https://fck-relay-ws.onrender.com/health').Content
}

switch ($target) {
  'phone'  { Start-PhoneRelease }
  'emu'    { Start-EmulatorRelease }
  'health' { Test-Keepalive }
  'both'   { Start-PhoneRelease; Start-EmulatorRelease }
}


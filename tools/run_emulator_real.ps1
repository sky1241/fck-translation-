param(
  [Parameter(Mandatory=$false)][string]$ApiKey,
  [Parameter(Mandatory=$false)][string]$BaseUrl,
  [Parameter(Mandatory=$true)][string]$RelayUrl,
  [Parameter(Mandatory=$true)][string]$Room,
  [Parameter(Mandatory=$false)][string]$Project
)

$ErrorActionPreference = "Stop"

if (-not $ApiKey) { $ApiKey = $env:OPENAI_API_KEY }
if (-not $BaseUrl) { $BaseUrl = ($env:OPENAI_BASE_URL); if (-not $BaseUrl) { $BaseUrl = 'https://api.openai.com/v1/chat/completions' } }
if (-not $Project -and $env:OPENAI_PROJECT) { $Project = $env:OPENAI_PROJECT }

flutter emulators | Out-Null
flutter run -d emulator-5554 --debug --no-resident `
  --dart-define=OPENAI_BASE_URL=$BaseUrl `
  --dart-define=OPENAI_API_KEY=$ApiKey `
  --dart-define=OPENAI_MODEL=gpt-4o-mini `
  $(if($Project){"--dart-define=OPENAI_PROJECT=$Project"}) `
  --dart-define=RELAY_WS_URL=$RelayUrl `
  --dart-define=RELAY_ROOM=$Room



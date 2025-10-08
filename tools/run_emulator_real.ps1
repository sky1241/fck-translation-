param(
  [Parameter(Mandatory=$true)][string]$ApiKey,
  [Parameter(Mandatory=$true)][string]$BaseUrl,
  [Parameter(Mandatory=$true)][string]$RelayUrl,
  [Parameter(Mandatory=$true)][string]$Room
)

$ErrorActionPreference = "Stop"

flutter emulators | Out-Null
flutter run -d emulator-5554 --debug --no-resident `
  --dart-define=OPENAI_BASE_URL=$BaseUrl `
  --dart-define=OPENAI_API_KEY=$ApiKey `
  --dart-define=OPENAI_MODEL=gpt-4o-mini `
  --dart-define=RELAY_WS_URL=$RelayUrl `
  --dart-define=RELAY_ROOM=$Room



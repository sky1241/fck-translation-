param(
  [Parameter(Mandatory=$true)][string]$ApiKey,
  [Parameter(Mandatory=$true)][string]$BaseUrl,
  [Parameter(Mandatory=$true)][string]$RelayUrl,
  [Parameter(Mandatory=$true)][string]$Room,
  [Parameter(Mandatory=$false)][string]$Project
)

$ErrorActionPreference = "Stop"

flutter run -d FMMFSOOBXO8T5D75 --debug --no-resident `
  --dart-define=OPENAI_BASE_URL=$BaseUrl `
  --dart-define=OPENAI_API_KEY=$ApiKey `
  --dart-define=OPENAI_MODEL=gpt-4o-mini `
  $(if($Project){"--dart-define=OPENAI_PROJECT=$Project"}) `
  --dart-define=RELAY_WS_URL=$RelayUrl `
  --dart-define=RELAY_ROOM=$Room

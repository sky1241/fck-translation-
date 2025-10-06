# One-click: start relay (if free) and run Edge (ZH→FR) bound to a fixed room
param(
  [string]$ApiKey,
  [string]$BaseUrl = "https://api.openai.com/v1/chat/completions",
  [string]$Model = "gpt-4o-mini",
  [string]$Room = "demo123",
  [int]$Port = 8765
)

$ErrorActionPreference='Stop'
function Start-RelayIfFree {
  param([int]$p)
  # If port already bound, skip
  try {
    $tcp = Get-NetTCPConnection -LocalPort $p -State Listen -ErrorAction Stop
    if ($tcp) { return }
  } catch {}
  Start-Process pwsh -ArgumentList "-NoProfile","-Command","cd tools; python relay_server.py" | Out-Null
}

if (-not $ApiKey) {
  if ($env:OPENAI_API_KEY) { $ApiKey = $env:OPENAI_API_KEY }
}
if (-not $ApiKey) { throw "OPENAI_API_KEY manquant. Passez -ApiKey ou définissez la variable d'environnement." }

Start-RelayIfFree -p $Port

$cmd = "flutter run -d edge --dart-define=OPENAI_BASE_URL=$BaseUrl --dart-define=OPENAI_API_KEY=$ApiKey --dart-define=OPENAI_MODEL=$Model --dart-define=CHAT_DEFAULT_DIRECTION=zh2fr --dart-define=CHAT_DEFAULT_TONE=casual --dart-define=CHAT_DEFAULT_PINYIN=false --dart-define=RELAY_WS_URL=ws://127.0.0.1:$Port --dart-define=RELAY_ROOM=$Room"
iex $cmd



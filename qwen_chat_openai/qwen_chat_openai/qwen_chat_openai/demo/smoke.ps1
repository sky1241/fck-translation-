$ErrorActionPreference="Stop"
$relayHealth=(iwr https://fck-relay-ws.onrender.com/health -UseBasicParsing).Content
$proxy="fck-openai-proxy.onrender.com"
$body=@{model="gpt-4o-mini";messages=@(@{role="user";content="ping"});max_tokens=1}|ConvertTo-Json -Compress
$code=(curl.exe -s -o NUL -w "%{http_code}" https://$proxy/v1/chat/completions -H "Authorization: Bearer $env:OPENAI_API_KEY" -H "OpenAI-Project: $env:OPENAI_PROJECT" -H "Content-Type: application/json" -d $body)
"RELAY_HEALTH=$relayHealth"
"PROXY_CODE=$code"


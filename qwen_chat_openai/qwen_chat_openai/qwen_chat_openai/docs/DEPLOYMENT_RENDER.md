## Stable deployment (Render Free)

This project exposes two backend components as Render Web Services (Free plan):
- OpenAI proxy (HTTP → HTTPS): Dockerfile.proxy
- Realtime relay (WebSocket): Dockerfile.relay

Service names and default URLs
- Proxy: fck-openai-proxy → https://fck-openai-proxy.onrender.com (endpoint: /v1/chat/completions)
- Relay: fck-relay-ws → wss://fck-relay-ws.onrender.com

What changed in the repo
- Added Dockerfile.proxy and Dockerfile.relay
- Added render.yaml (blueprint)
- tools/openai_proxy.dart now binds 0.0.0.0 for container hosting

How to deploy (GUI)
1) In Render → New Web Service → connect GitHub repo.
2) Proxy service:
   - Root Directory: qwen_chat_openai
   - Dockerfile Path: Dockerfile.proxy
   - Plan: Free
   - Optional env vars: OPENAI_SERVER_API_KEY, OPENAI_PROJECT
3) Relay service:
   - Root Directory: qwen_chat_openai
   - Dockerfile Path: Dockerfile.relay
   - Plan: Free

Validation
- Proxy: opening /v1/chat/completions must return 401 or 405 (not DNS error).
- Relay: used via wss://fck-relay-ws.onrender.com in the mobile app.

Mobile configuration (dart-define)
- OPENAI_BASE_URL=https://fck-openai-proxy.onrender.com/v1/chat/completions
- RELAY_WS_URL=wss://fck-relay-ws.onrender.com
- RELAY_ROOM=demo123

APK build (release)
```
flutter build apk --release \
  --dart-define=OPENAI_BASE_URL=https://fck-openai-proxy.onrender.com/v1/chat/completions \
  --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY \
  --dart-define=OPENAI_PROJECT=$env:OPENAI_PROJECT \
  --dart-define=OPENAI_MODEL=gpt-4o-mini \
  --dart-define=RELAY_WS_URL=wss://fck-relay-ws.onrender.com \
  --dart-define=RELAY_ROOM=demo123
```

Notes
- Free plan may cold-start (a few seconds) after inactivity.
- For server-signed auth, set OPENAI_SERVER_API_KEY in Render; otherwise the app sends its key.



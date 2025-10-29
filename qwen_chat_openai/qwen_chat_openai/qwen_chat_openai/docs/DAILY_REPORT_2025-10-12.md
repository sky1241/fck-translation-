## Daily Report — 2025-10-12

### What we built/secured today
- Stable realtime chat FR ↔ ZH across devices (phone + emulator) with a Render WS relay and OpenAI Chat Completions.
- Robust proxy and client:
  - Proxy hardened (no-crash guards, 502 on upstream errors)
  - WebSocket client auto-reconnect + tolerant UTF‑8/binary
- App defaults set to stable URLs; UTC timestamps stored; local rendering.
- Release pipeline made reliable on Windows: no-shrink build, Gradle/DEX locks neutralized (stop/clean), adb install without prompt.
- Branding: SVG logo committed; PNG generation path via Inkscape CLI; launcher icons wiring in place.

### Key issues and fixes
- 503 from proxy (Render): added /health, keepalive (10 min) + fallback direct OpenAI for tests.
- 401 invalid_api_key (sk-proj): added OpenAI-Project header end-to-end.
- WS format exceptions: client+relay now decode binary with allowMalformed; added reconnect.
- PowerShell pitfalls: ensured one-line commands, no backticks ambiguity, device/emu detection.
- Android build/install errors:
  - INSTALL_FAILED_USER_RESTRICTED → Dev options + install via USB; auto adb settings in scripts
  - R8/minify locks and FileSystemException on classes.dex/libflutter.so → build --no-shrink + gradle --stop + clean; kill java/gradle
  - Icon not updating → regenerate icons, clean, reinstall (launcher cache may need restart)

### Current test configuration
- RELAY_WS_URL: wss://fck-relay-ws.onrender.com
- RELAY_ROOM: test123 (use identical value on both apps)
- OPENAI_BASE_URL (test fallback): https://api.openai.com/v1/chat/completions
- Model: gpt-4o-mini

### One-liner runs (release)
- Phone:
```powershell
cd "C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai"
flutter run -d FMMFSOOBXO8T5D75 --release --no-resident `
  --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions `
  --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY `
  --dart-define=OPENAI_PROJECT=$env:OPENAI_PROJECT `
  --dart-define=OPENAI_MODEL=gpt-4o-mini `
  --dart-define=RELAY_WS_URL=wss://fck-relay-ws.onrender.com `
  --dart-define=RELAY_ROOM=test123
```
- Emulator API 30:
```powershell
$proj="C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai"; cd $proj
$avd="ChatAPI30Lite"; flutter emulators --launch $avd | Out-Null; Start-Sleep 10
$emu=(adb devices | Select-String "^emulator-" | % { ($_ -split "\s+")[0] } | Select-Object -First 1)
flutter run -d $emu --release --device-timeout 180 --no-resident `
  --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions `
  --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY `
  --dart-define=OPENAI_PROJECT=$env:OPENAI_PROJECT `
  --dart-define=OPENAI_MODEL=gpt-4o-mini `
  --dart-define=RELAY_WS_URL=wss://fck-relay-ws.onrender.com `
  --dart-define=RELAY_ROOM=test123
```

### Skills demonstrated (for CV/portfolio)
- End-to-end mobile realtime system: Flutter/Dart client, Render-hosted WS relay, OpenAI integration with project-scoped keys.
- Production hardening: graceful proxy error handling, WS reconnect, Azure-like SRE checks (/health + keepalive), CI that generates Freezed/JSON.
- Android release economics on Windows: gradle/adb reliability, no-shrink strategy, automated PowerShell workflows.
- Diagnostics under pressure: iterating on network, build, and emulator constraints to reach stable release.

### Next suggested steps
- Finalize icon polish (PNG now auto-generated via Inkscape; increase foreground scale as desired and regenerate).
- Optional: switch proxy to always-on plan or keepalive < 10 min for zero 503 risk.
- Freeze a production room name and produce a final signed APK for sharing.



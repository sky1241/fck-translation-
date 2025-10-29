## Key Decisions

Frontend
- Flutter (Android focus) with compile-time `--dart-define` config (no runtime settings to avoid state drift).
- Store UTC timestamps; render local time.
- WebSocket: auto-reconnect; tolerant UTF‑8; rooms via query string.

Backend
- Render hosts two small Dart services: `relay` (WS) and `proxy` (OpenAI forwarder).
- `/health` endpoints for both; GitHub Actions keepalive every 10 minutes.
- Proxy never crashes: returns 502 for upstream/timeout errors; short timeouts.

Build/CI
- CI runs build_runner, analyze, tests; skips APK build (faster and stable).
- Release builds on dev machine use `--no-shrink` to avoid R8 lockups on Windows.

Ops
- One-liner PowerShell scripts for phone/emulator (release, no-resident).
- Fallback direct OpenAI endpoint during tests to bypass any proxy cold starts.


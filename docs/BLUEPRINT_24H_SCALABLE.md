## Scalable 24h Blueprint — Realtime FR↔ZH Chat (Render + Flutter)

### 0) North Star (what “done” looks like)
- Two Android clients (phone + emulator) exchanging messages realtime via WS relay in <2s.
- OpenAI translation working with sk-proj + OpenAI-Project header.
- Release APK built, installable in 1 command, no dev PC dependency.
- Keepalive prevents cold starts; app survives intermittent relay/proxy outages.

### 1) Reference Architecture
- Client (Flutter):
  - WS → Relay (wss)
  - HTTPS → OpenAI (direct) or Proxy (Render)
  - Compile-time config via `--dart-define` (no runtime config UI)
  - UTC timestamps; local display; WS auto-reconnect; tolerant UTF-8
- Backend (Render):
  - `relay` (Dart, WS, rooms via query)
  - `proxy` (Dart, forwards to OpenAI; returns 502 on upstream errors)
  - `/health` endpoints
  - GitHub Actions keepalive (ping /health + dummy completion every 10m)
- CI:
  - build_runner before analyze/tests; no APK build on CI

### 2) 24h Execution Plan (battle-tested)
Hour 0–2: Bootstrap
- Clone template; set `AppEnv` defaults to Render URLs.
- Add translation service with project header; add WS client with auto-reconnect.

Hour 2–6: Realtime + Translation
- Implement send/receive; use `RELAY_WS_URL` + `RELAY_ROOM`.
- Add `safeJsonDecode`, retry for HTTP 429/5xx.

Hour 6–10: Packaging
- Add Inkscape pipeline to rasterize SVG → PNG 1024; `flutter_launcher_icons`.
- PowerShell scripts for run phone/emulator (release, no-resident, no-shrink).

Hour 10–16: Backend Deploy (Render)
- Build tiny Dart AOT images for `proxy`/`relay` (no Flutter SDK).
- `render.yaml` with two services; Root/Context fixed.
- Add `/health`; deploy; verify with curl.

Hour 16–20: Reliability
- GH Actions keepalive (cron 10m); room existence = on connect.
- Harden proxy (timeouts, 502 on errors) + WS auto-reconnect.

Hour 20–24: Release + Handoff
- Build APK release no-shrink; ADB install w/o prompts.
- Final smoke tests: phone+emulator, same room.

### 3) Golden Commands (operator quicksheet)
- Phone (release): see DAILY_REPORT_2025-10-12.md → One-liners
- Emulator (release): same doc → One-liners
- Keepalive check: `iwr https://<service>/health`

### 4) Failure Modes → Fast Fix
- 401 invalid_api_key → add `OpenAI-Project` header; use `sk-proj`.
- 503 proxy → fallback direct `OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions`; keepalive.
- WS no messages → mismatch `RELAY_WS_URL`/`RELAY_ROOM`; fix both; client reconnects.
- ADB INSTALL_FAILED_USER_RESTRICTED → enable “Installer via USB”; adb global toggles.
- Gradle/R8 lock or FileSystemException → `--no-shrink` + `gradlew --stop` + `flutter clean` + kill `java/gradle`.
- Icon not updating → regenerate PNG + launcher icons; clean; reinstall; restart launcher once.

### 5) Guardrails (code/ops)
- Client: store times UTC; display local; never crash on WS frame parse.
- Proxy: never `exit 255`; always close responses; short idle/conn timeouts.
- CI: run build_runner; skip slow APK builds.
- Scripts: phone/emulator one-liners; kill locks; explicit device targeting.

### 6) Security & Keys
- Prefer direct OpenAI on client only for tests; in prod, put `OPENAI_SERVER_API_KEY` on proxy.
- Never commit keys; use env/Secrets; avoid logging secrets.

### 7) Reuse Kit (copy/paste list)
- Files: `tools/relay_server.dart`, `tools/openai_proxy.dart`, `render.yaml`, `docs/DAILY_REPORT_YYYY-MM-DD.md`, this blueprint.
- Scripts: release phone/emulator runners; Inkscape raster step; keepalive workflow.

### 8) What changed our speed (leverage)
- One-liners deterministic; Render URLs baked; fallback OpenAI direct for tests.
- `--no-shrink` eliminated R8 tail-chase.
- Auto-reconnect WS + tolerant decoding removed flakiness.
- Keepalive masked free-tier cold starts.

### 9) Exit Criteria Checklist
- [ ] Phone+Emulator in same room receive each other’s messages <2s
- [ ] Translation content returned without 401/503 (or direct OpenAI fallback active)
- [ ] APK release installs w/o prompt
- [ ] Icon visible (after reinstall/launcher restart)
- [ ] /health OK for proxy + relay; keepalive running



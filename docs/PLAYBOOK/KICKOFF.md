## Project Kickoff (fast, repeatable)

Goal: start any similar chat app and reach stable release in <24h.

1) Freeze requirements (15 min)
- Purpose (1 line), supported pairs (FR↔ZH), realtime target (<2s), minimal UI
- Infra choice: Render WS relay + OpenAI direct (tests) + optional proxy
- One room name for tests (e.g. `test123`); production room to be decided later

2) Secrets & env (5 min)
- `OPENAI_API_KEY` (sk‑proj‑…), `OPENAI_PROJECT` (proj_…)
- Never commit keys; verify `curl` to `https://api.openai.com/v1/models` (200)

3) Scaffold code (30 min)
- AppEnv defaults: `RELAY_WS_URL`, `RELAY_ROOM`, `OPENAI_BASE_URL` (Render or direct)
- WS client: auto‑reconnect, tolerant UTF‑8/binary
- Translation service: project header, 429 retry, safe JSON
- Timestamps: store UTC, display local

4) Backend deploy (45 min)
- Relay: Dart WS with `/health`; rooms via `?room=`; return text frames
- Proxy (optional): forwards Chat Completions; never crash (502 on error)
- Render blueprint + deploy; verify `/health`
- GH Actions keepalive (10 min): ping `/health` + minimal completion

5) Android pipeline (45 min)
- PowerShell one‑liners for phone/emulator (release, `--no-resident`)
- Build with `--no-shrink`; add gradle/java kill + clean guards
- ADB settings to avoid “user restricted” prompts (dev options)

6) Branding (30 min)
- SVG → PNG 1024 via Inkscape CLI: `inkscape app_logo.svg -o app_logo_1024.png -w 1024 -h 1024`
- `flutter_launcher_icons` with PNG; clean + reinstall

7) Test plan (30 min)
- Phone + emulator, same `RELAY_WS_URL` and `RELAY_ROOM`
- Send text, receive in <2s, translation OK; rotate both directions
- Proxy fallback: switch OPENAI_BASE_URL direct to bypass 503

8) CI/Docs (30 min)
- CI: build_runner → analyze/test; skip APK build
- Docs: Daily report + this playbook; copy “COMMANDS.ps1” into repo

Common pitfalls (and fixes)
- 503 proxy: direct OpenAI fallback + keepalive
- No messages: mismatch room/url → fix both, client reconnects
- INSTALL_FAILED_USER_RESTRICTED: enable “Installer via USB” + adb toggles
- R8/DEX locks: `--no-shrink` + `gradlew --stop` + clean + kill java/gradle
- Icon unchanged: regenerate PNG + launcher icons; clean; reinstall; restart launcher



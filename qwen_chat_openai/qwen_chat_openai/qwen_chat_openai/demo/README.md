## Demo Pack (fixed, reusable)

Goal
- Run a demonstrable realtime chat with fixed, known-good values in <5 minutes.

Fixed values
- RELAY_WS_URL = wss://fck-relay-ws.onrender.com
- RELAY_ROOM = test123
- OPENAI_BASE_URL (demo) = https://api.openai.com/v1/chat/completions
- MODEL = gpt-4o-mini

How to use
- 1) Run smoke checks: `./smoke.ps1`
- 2) Phone demo (release): `./demo_phone.ps1`
- 3) Emulator demo (release): `./demo_emulator.ps1`

Prereqs
- PowerShell 7+, adb, flutter, Android SDK; env set: `OPENAI_API_KEY`, `OPENAI_PROJECT`.

Notes
- These scripts build with `--no-shrink`, apply ADB toggles to avoid prompts, and are idempotent.


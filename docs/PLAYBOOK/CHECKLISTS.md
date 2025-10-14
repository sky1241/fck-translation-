## Checklists

Phone (release) — 2 min
1) Set env: `OPENAI_API_KEY`, `OPENAI_PROJECT`
2) Run (copy/paste): see COMMANDS.ps1 → Phone Release
3) Send a message; confirm peer receives in <2s

Emulator API 30 (release)
1) Launch AVD (ChatAPI30Lite)
2) Run (copy/paste): see COMMANDS.ps1 → Emulator Release
3) Confirm realtime + translation

Proxy/Relay smoke test
- `iwr https://fck-openai-proxy.onrender.com/health`
- `iwr https://fck-relay-ws.onrender.com/health`

Icon update
1) Edit SVG
2) `inkscape app_logo.svg -o app_logo_1024.png -w 1024 -h 1024`
3) `dart run flutter_launcher_icons -f flutter_launcher_icons.yaml`
4) Clean + build + reinstall


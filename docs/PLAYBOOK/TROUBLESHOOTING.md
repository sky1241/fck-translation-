## Troubleshooting (symptom → fix)

HTTP 503 (proxy)
- Use direct OpenAI `OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions`
- Keepalive runs every 10m; proxy returns 502 on upstream errors (no crash)

No realtime messages
- Ensure BOTH apps use same `RELAY_WS_URL` and `RELAY_ROOM`
- Client reconnects automatically; relay `/health` must be `{status:ok}`

INSTALL_FAILED_USER_RESTRICTED
- Enable Dev options → “Installer via USB”; run adb toggles in scripts

Gradle/R8 locks (classes.dex/libflutter.so errors)
- Build with `--no-shrink`, `gradlew --stop`, `flutter clean`, kill `java/gradle`

Icon not updating
- Regenerate `app_logo_1024.png` via Inkscape, run `flutter_launcher_icons`, clean, reinstall, restart launcher if needed


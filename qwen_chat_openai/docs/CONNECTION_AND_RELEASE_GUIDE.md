# FR↔ZH Chat – Connection, Badges, Release

## What gets stored
- Local-only history in SharedPreferences under key `qwen_chat_messages_v1` (per device).

## Realtime link (WebSocket relay)
- Both clients must share the same room.
- Use a reachable RELAY_WS_URL:
  - Phone ↔ PC on same LAN: `ws://PC_IP:8765` (NOT 127.0.0.1 on phone)
  - Emulator/phone (Render relay): `wss://fck-relay-ws.onrender.com`
  - Internet (recommended for “no touch” release): `wss://your-domain:8765`

Required defines (examples):
```
--dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions \
--dart-define=OPENAI_API_KEY=*** \
--dart-define=OPENAI_MODEL=gpt-4o-mini \
--dart-define=CHAT_DEFAULT_DIRECTION=fr2zh   # or zh2fr \
--dart-define=CHAT_DEFAULT_TONE=casual \
--dart-define=CHAT_DEFAULT_PINYIN=true \
--dart-define=RELAY_WS_URL=ws://PC_IP:8765   # or wss://your-domain:8765 \
--dart-define=RELAY_ROOM=demo123
```

## Notifications and badge
- Android local notification pops on incoming messages.
- Badge count increments on incoming; resets when opening `ChatPage`.
- Badge display depends on launcher; ensure icon badges/pastilles are enabled.

## Quick test matrix
- Web (host PC): run with RELAY_WS_URL=`ws://PC_IP:8765` and room `demo123`.
- Phone: install app; run/build with the same RELAY settings.
- Emulator/phone: use RELAY_WS_URL=`wss://fck-relay-ws.onrender.com`.

## Stable “no-touch” release
1) Host relay on the internet (wss) with a fixed room.
2) Build release with those fixed `--dart-define` values.
3) Distribute the APK; the app auto-connects on startup.

## Emulator notes (Android Studio)
- Prefer API 30 Google APIs x86_64; cold boot; RAM ~2GB.
- If GPU issues: launch with `-accel off -gpu off -no-boot-anim -no-snapshot-load`.
- For LAN relay on same PC: use `10.0.2.2`.

## Troubleshooting
- “System UI isn’t responding” = emulator/GPU issue. Use software GL or try API 28/30.
- No sync on phone = likely RELAY_WS_URL incorrectly set to 127.0.0.1; use PC_IP or wss://.
- No badge = enable icon badges in launcher settings or use a launcher supporting badges.



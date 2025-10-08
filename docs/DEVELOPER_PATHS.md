## Developer paths and runtime defines

### Core runtime defines
- **OPENAI_BASE_URL**, **OPENAI_API_KEY**, **OPENAI_MODEL**
- **CHAT_DEFAULT_DIRECTION**: "fr2zh" | "zh2fr"
- **CHAT_DEFAULT_TONE**: string (e.g., "casual")
- **CHAT_DEFAULT_PINYIN**: true | false
- **RELAY_WS_URL**: ws/wss URL (e.g., ws://PC_IP:8765)
- **RELAY_ROOM**: string room id (e.g., demo123)
- **UPLOAD_BASE_URL**: optional cloud upload base URL

File: `lib/core/env/app_env.dart`
- Reads all `--dart-define` values at build/run time.

### Realtime relay
- File: `tools/relay_server.py` (start with `python tools/relay_server.py`, default port 8765)
- File: `lib/core/network/realtime_service.dart` (connects to `RELAY_WS_URL?room=RELAY_ROOM`)
- LAN test:
  - Phone/PC: `RELAY_WS_URL=ws://PC_IP:8765`
  - Android emulator (same PC): `RELAY_WS_URL=ws://10.0.2.2:8765`
- Release: use a public `wss://` URL and fixed room.

### Chat logic
- File: `lib/features/chat/presentation/chat_controller.dart`
  - Applies defaults (direction, tone, pinyin)
  - Listens to relay → `_receiveRemote` (text) or `_receiveRemoteAttachment`
  - `send(text)`: append local → translate → reply bubble
  - `sendAttachment()`: picker → upload (multipart if `UPLOAD_BASE_URL`, else base64 fallback) → relay broadcast
  - Notifications/badges: increments on incoming; clears when opening chat

### UI
- `lib/features/chat/presentation/chat_page.dart` (main chat screen)
- `lib/features/chat/presentation/widgets/composer_bar.dart` (input + send + add-photo)
- `lib/features/chat/presentation/widgets/attachment_bubble.dart` (image viewer)

### Models
- `lib/features/chat/data/models/chat_message.dart` (now includes `attachments`)
- `lib/features/chat/data/models/attachment.dart` (`Attachment`, `AttachmentDraft`, `AttachmentStatus`)

### Media & transfer
- `lib/core/media/attachment_picker_service.dart` (image_picker)
- `lib/core/network/upload/upload_service.dart` (interface, progress)
- `lib/core/network/upload/cloud_upload_service.dart` (multipart upload or base64 fallback)
- `lib/core/network/download/download_service.dart` (skeleton)

### Notifications & badges
- `lib/core/network/notification_service_mobile.dart` (Android, numeric `number`)
- `lib/core/network/notification_service_web.dart` (browser Notification API)
- `lib/core/network/badge_service.dart` (flutter_app_badger)

### App bootstrap
- `lib/main.dart` (ensureInitialized, notifications init)
- `lib/app.dart` (MaterialApp, darkTheme, ThemeMode.dark, startup routing)

### Android
- `android/app/src/main/AndroidManifest.xml` (INTERNET, POST_NOTIFICATIONS, media permissions)

### Dependencies
- `pubspec.yaml` (web_socket_channel, flutter_local_notifications, flutter_app_badger, image_picker, dio, etc.)

### Dev commands (LAN)
- Start relay:
```bash
python tools/relay_server.py
```
- Web client (ZH→FR):
```bash
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 5500 \
  --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions \
  --dart-define=OPENAI_API_KEY=... \
  --dart-define=OPENAI_MODEL=gpt-4o-mini \
  --dart-define=CHAT_DEFAULT_DIRECTION=zh2fr \
  --dart-define=CHAT_DEFAULT_TONE=casual \
  --dart-define=CHAT_DEFAULT_PINYIN=false \
  --dart-define=RELAY_WS_URL=ws://PC_IP:8765 \
  --dart-define=RELAY_ROOM=demo123
```
- Phone (FR→ZH):
```bash
flutter run -d <deviceId> \
  --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions \
  --dart-define=OPENAI_API_KEY=... \
  --dart-define=OPENAI_MODEL=gpt-4o-mini \
  --dart-define=CHAT_DEFAULT_DIRECTION=fr2zh \
  --dart-define=CHAT_DEFAULT_TONE=casual \
  --dart-define=CHAT_DEFAULT_PINYIN=true \
  --dart-define=RELAY_WS_URL=ws://PC_IP:8765 \
  --dart-define=RELAY_ROOM=demo123
```
- Emulator (ZH→FR, same PC): use `RELAY_WS_URL=ws://10.0.2.2:8765`

### Release (fixed liaison)
- Set: `RELAY_WS_URL=wss://your-relay`, `RELAY_ROOM=your-room`
- Optional: `UPLOAD_BASE_URL=https://your-upload-api`
- Build:
```bash
flutter build apk --release \
  --dart-define=RELAY_WS_URL=wss://your-relay \
  --dart-define=RELAY_ROOM=your-room \
  --dart-define=CHAT_DEFAULT_DIRECTION=fr2zh \
  --dart-define=UPLOAD_BASE_URL=https://your-upload-api
```

### Tools
- `tools/run_two_instances.ps1` (helper to launch multi-clients with defines)
- `dist/` (store built APKs to share over LAN)
- `.github/workflows/flutter-ci.yml` (CI)

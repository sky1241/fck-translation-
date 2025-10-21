## Shipping a cross-device translation chat with stable cloud backends (2025-10-10)

Scope
- Stabilized Android app startup and UI; enabled real-time cross-device messaging; added stable public backends; prepared one‑click APK distribution.

Key contributions
- Android build and runtime fixes: notification icon resource, Java 8 desugaring, removal of deprecated badge plugin; robust init with try/catch; post-frame navigation to eliminate black screen.
- UX improvements: local image attachments, consistent white timestamps, auto-scroll to bottom on open.
- OpenAI integration: support for `OpenAI-Project` header; mock fallback removed for production; server-side proxy added.
- Realtime: implemented lightweight WebSocket relay in Dart for inter-client messaging.
- Cloud deployment: containerized proxy and relay; deployed on Render Free with fixed URLs; documented blueprint; enabled reproducible runs via `--dart-define` and release APK build.

Tech highlights
- Flutter/Dart, Android, Riverpod; WebSocket; Docker; Render (containers on Free plan); CI-friendly blueprint (`render.yaml`).
- Secure config via env vars and dart-define; optional server-signed OpenAI auth.

Artifacts
- Dockerfile.proxy, Dockerfile.relay, tools/openai_proxy.dart, tools/relay_server.dart
- Docs: DEPLOYMENT_RENDER.md with validation steps and release build command

Outcome
- Two stable endpoints:
  - Proxy: https://fck-openai-proxy.onrender.com/v1/chat/completions
  - Relay: wss://fck-relay-ws.onrender.com
- Ready-to-share release APK with baked configuration for zero-setup install.



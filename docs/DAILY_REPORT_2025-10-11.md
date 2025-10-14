
## Daily Report — 2025-10-11

### Overview
- Goal: rendre la messagerie FR ↔ ZH fiable en production (temps réel, stable, partageable).
- Outcome: services Render stables, app Flutter durcie, keep‑alive automatique, CI assainie.

### Deliverables
- Stable endpoints (Render):
  - OpenAI proxy: `https://fck-openai-proxy.onrender.com/v1/chat/completions`
  - WS relay: `wss://fck-relay-ws.onrender.com`
- App defaults: `lib/core/env/app_env.dart` pointe par défaut sur ces URLs (plus besoin de `--dart-define` pour les URLs).
- Health checks: endpoints `/health` sur proxy et relay.
- Keepalive: workflow GitHub Actions planifié toutes 5 min (`.github/workflows/keepalive.yml`).
- CI: workflow Flutter nettoyé pour “analyze + test” uniquement (pas d’APK en CI).

### Changes (code)
- Realtime/WS durci: décodage tolérant binaire/UTF‑8 mal formé
  - `lib/core/network/realtime_service.dart`: `utf8.decode(..., allowMalformed: true)` + parsing robuste.
  - `tools/relay_server.dart`: relai texte, tolérance binaire + `/health`.
- Proxy: `tools/openai_proxy.dart`
  - Ajout de `/health`; gestion d’erreurs + en‑têtes; écoute 0.0.0.0.
- Environnements par défaut: `app_env.dart`
  - `OPENAI_BASE_URL` → proxy Render (par défaut).
  - `RELAY_WS_URL` → relay Render (par défaut).
- CI/CD:
  - `.github/workflows/flutter-ci.yml`: suppression du build APK (instable côté CI), conserve `flutter analyze` et `flutter test`.
  - `.github/workflows/keepalive.yml`: pings `/health` toutes 5 min.

### Incidents et résolutions (timeline)
- FormatException “Missing extension byte”: causé par frames binaires WS → corrigé côté client + relay (décodage tolérant).
- 503 Render (cold start): mitigé via keepalive cron; smoke tests OK (200 proxy, “WebSocket only” relay en HTTP).
- Erreurs PowerShell (device/emulator/line breaks): commandes consolidées en une ligne, détection `$emu`, API 30 conseillée.

### Playbook (rappels)
- Smoke tests
  - Relay: `Invoke-WebRequest https://fck-relay-ws.onrender.com -UseBasicParsing | % Content` → “WebSocket only” attendu.
  - Proxy: `curl -s -o NUL -w "%{http_code}\n" https://fck-openai-proxy.onrender.com/v1/chat/completions -H "Authorization: Bearer $env:OPENAI_API_KEY" -H "OpenAI-Project: $env:OPENAI_PROJECT" -H "Content-Type: application/json" -d '{"model":"gpt-4o-mini","messages":[{"role":"user","content":"ping"}],"max_tokens":1}'` → 200 attendu.
- Lancer téléphone (URLs déjà intégrées):
  - `flutter run -d <DEVICE_ID> --no-resident --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY --dart-define=OPENAI_PROJECT=$env:OPENAI_PROJECT --dart-define=OPENAI_MODEL=gpt-4o-mini --dart-define=RELAY_ROOM=demo123`
- Lancer émulateur (API 30 recommandé):
  - Une ligne robuste avec détection `$emu` comme fournie dans la conversation.
- APK release “baked” (URLs déjà par défaut):
  - `flutter build apk --release --dart-define=OPENAI_API_KEY=... --dart-define=OPENAI_PROJECT=... --dart-define=OPENAI_MODEL=gpt-4o-mini --dart-define=RELAY_ROOM=demo123`

### Décisions
- Abandon des tunnels éphémères; standardisation Render (proxy + relay).
- Keepalive GitHub Actions pour éviter les cold starts.
- URLs stables intégrées au code par défaut; variables sensibles continuent via `--dart-define`.

### Prochains pas
- Construire et signer l’APK release à partager (keystore + `key.properties`).
- Nettoyage final des notes “quick tunnel” (archivage) et docs unifiées autour de Render.

### Notes
- Première requête après inactivité: léger délai possible (mitigé par keepalive).
- Même `RELAY_ROOM` sur les deux appareils.



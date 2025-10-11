## Lancer en mode réel (Android Studio Copilot)

Pré-requis: Avoir la clé OpenAI en variable d'environnement `OPENAI_API_KEY` (ne pas commiter de secrets).

### 1) Démarrer le relais WebSocket (sur le PC)

Terminal PC:
```bash
dart run tools/relay_server.dart 8765
```

Note IP: Utiliser l'IP LAN du PC (ex: 192.168.x.y). Sur un émulateur Android du même PC, utiliser `ws://10.0.2.2:8765`.

### 2) Lancer sur téléphone (réel)

Terminal PC (ou Copilot exécute la commande):
```bash
powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_phone_real.ps1 `
  -ApiKey $env:OPENAI_API_KEY `
  -BaseUrl https://api.openai.com/v1/chat/completions `
  -RelayUrl ws://192.168.x.y:8765 `
  -Room demo123
```

### Lancement « une seule ligne » (PowerShell)

Pré‑requis: variables d’environnement (OPENAI_API_KEY, OPENAI_PROJECT) et tunnel Cloudflare actif.

Exemple (host actuel):
```powershell
cd "C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai"; flutter run -d FMMFSOOBXO8T5D75 --debug --no-resident --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY --dart-define=OPENAI_PROJECT=$env:OPENAI_PROJECT --dart-define=OPENAI_MODEL=gpt-4o-mini --dart-define=RELAY_WS_URL=wss://computation-world-committed-involves.trycloudflare.com --dart-define=RELAY_ROOM=demo123
```

Modèle générique:
```powershell
cd "C:\\Users\\<user>\\OneDrive\\Bureau\\fck trans\\fck-translation-\\qwen_chat_openai"; flutter run -d <deviceId> --debug --no-resident --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY --dart-define=OPENAI_PROJECT=$env:OPENAI_PROJECT --dart-define=OPENAI_MODEL=gpt-4o-mini --dart-define=RELAY_WS_URL=wss://WSS_HOST --dart-define=RELAY_ROOM=demo123
```

### 3) Lancer sur émulateur

```bash
powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_emulator_real.ps1 `
  -ApiKey $env:OPENAI_API_KEY `
  -BaseUrl https://api.openai.com/v1/chat/completions `
  -RelayUrl ws://10.0.2.2:8765 `
  -Room demo123
```

### Remarques
- Aucune UI de réglages n'est exposée dans l'app; tout passe par les `--dart-define`.
- Le relais n'est requis que pour simuler un chat à deux appareils/émulateurs.
- Les images locales s'affichent immédiatement; l'upload distant est optionnel.


### Journal 2025-10-10

- Démarrage: écran noir corrigé (icône notif `ic_stat_notification`, init sécurisé + post-frame nav).
- Build Android: retrait `flutter_app_badger`, desugaring Java 8 activé; nettoyage des références à `SettingsPage`.
- OpenAI: ajout `OPENAI_PROJECT` et entête `OpenAI-Project`; fallback mock seulement si clés absentes.
- UI: images locales via `FileImage`; horodatage en blanc; auto‑scroll en bas à l'ouverture.
- Relay temps réel: serveur WS local (`tools/relay_server.dart`) exposé via Cloudflare Tunnel (wss). Utiliser le même `RELAY_WS_URL` et `RELAY_ROOM` sur les deux apps.
- Emulateur: stabilité en API 30 (désactivation Wellbeing/QuickSearchBox, animations à 0, ciblage `adb -s <emu>` pour éviter "more than one device").
- Clavier chinois: Sogou indisponible en x86_64 pour AVD → décision de tester Sogou sur téléphone réel (ARM64) et laisser l'AVD en FR (Gboard/SwiftKey possibles). Installation Sogou effectuée avec succès côté téléphone.

Bloc exécution final (exemple)

```powershell
# Téléphone réel
cd "C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai"; flutter run -d FMMFSOOBXO8T5D75 --no-resident --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY --dart-define=OPENAI_PROJECT=$env:OPENAI_PROJECT --dart-define=OPENAI_MODEL=gpt-4o-mini --dart-define=RELAY_WS_URL=wss://<host_trycloudflare> --dart-define=RELAY_ROOM=demo123

# Émulateur API 30 (déjà lancé)
$emu=(adb devices | sls "^emulator-" | % { ($_ -split "\s+")[0] } | select -First 1)
cd "C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai"; flutter run -d $emu --device-timeout 180 --no-resident --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY --dart-define=OPENAI_PROJECT=$env:OPENAI_PROJECT --dart-define=OPENAI_MODEL=gpt-4o-mini --dart-define=RELAY_WS_URL=wss://<host_trycloudflare> --dart-define=RELAY_ROOM=demo123
```

Notes rapides
- Si l'URL `trycloudflare` change, relancer les deux apps avec la nouvelle valeur.
- Toujours cibler l'AVD avec `adb -s <emu>` et `flutter -d <emu>` quand le téléphone est branché.


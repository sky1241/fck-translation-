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



# qwen_chat_openai

Chat FR ↔ ZH (zh-Hans) basé sur OpenAI Chat Completions (ChatGPT), UI type WhatsApp.

## Rapport du 2025-10-06

Ce qui a été fait aujourd'hui:

- Paramétrage compile-time des préférences: direction (FR→ZH / ZH→FR), ton, pinyin.
- Ajout d'un service de traduction robuste (JSON strict + fallback extraction).
- Mise en place d'un relay WebSocket minimal et intégration temps réel (Edge ↔ Android).
- Script PowerShell pour lancer deux instances (émulateur/téléphone) et web.
- Sécurisation: prise en charge des clés via `--dart-define`, variables d'env, ou fichier local ignoré.
- Corrections UI/flux: envoi en file d'attente, gestion 429, direction swap, réception relay sans écho.

Points restants/risques:

- Windows Desktop nécessite Developer Mode pour les plugins; on utilise Edge pour le web.
- Émulateur Android non disponible localement (SDK non configuré); téléphone + Edge OK.
- Plusieurs dépendances ont des mises à jour majeures (audit prévu avant montée de version).

## Configuration

Ne commitez aucun secret. Utilisez `--dart-define`:

```bash
flutter pub get
flutter run \
  --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions \
  --dart-define=OPENAI_API_KEY=sk-XXXX \
  --dart-define=OPENAI_MODEL=gpt-4o-mini
```

## Build APK (test direct sur téléphone)

```bash
flutter build apk --release \
  --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions \
  --dart-define=OPENAI_API_KEY=sk-XXXX \
  --dart-define=OPENAI_MODEL=gpt-4o-mini
```

## Mode Mock (tests sans API)

Pour tester sans appeler l’API (aucun quota requis):

```bash
flutter run \
  --dart-define=MOCK_MODE=true
```
L’app renverra une traduction factice et (si cible=zh) un pinyin mock, permettant de valider l’UI, la file de conversation, le clear et l’autoscroll.

## Tests temps réel en local (sans proxy Render)

- Démarrer le relay WebSocket local:
```bash
dart run tools/relay_server.dart 8765
```
- Lancer le web (Edge) avec le relay local:
```bash
flutter run -d edge -t lib/main.dart \
  --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions \
  --dart-define=OPENAI_API_KEY=sk-XXXX \
  --dart-define=OPENAI_MODEL=gpt-4o-mini \
  --dart-define=RELAY_WS_URL=ws://127.0.0.1:8765 \
  --dart-define=RELAY_ROOM=test123
```
- Lancer l’émulateur Android (room identique) avec mapping `10.0.2.2`:
```bash
pwsh -NoProfile -ExecutionPolicy Bypass -File "docs/PLAYBOOK/COMMANDS.ps1" -target emu -UseLocalRelay -DirectOpenAI
```

Notes:
- `127.0.0.1` vu depuis le navigateur (host) ≠ `127.0.0.1` dans l’émulateur; utiliser `10.0.2.2` côté Android pour joindre l’hôte.
- Si le port 8765 est occupé, tuer le processus ou choisir un autre port.

## Fonctionnalités

- Traduction FR ⇄ ZH (zh-Hans) directionnelle avec ton (casual/affectionate/business)
- JSON strict côté sortie, fallback extraction {...}
- Persistance locale des messages (`shared_preferences`)
- UI type WhatsApp (texte, pinyin optionnel côté ZH)

## OpenAI API - Achat et clé

- Crée/active la facturation API ici (car ChatGPT Plus ne couvre pas l’API):
  - https://platform.openai.com/account/billing/overview
  - Ajoute un moyen de paiement et fixe un hard limit mensuel.
- Génère une clé API (sk-...) ici:
  - https://platform.openai.com/api-keys
- Ne committe jamais la clé. Passe-la au runtime avec --dart-define.

Exemple exécution Dev (OpenAI):
```bash
flutter run \
  --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions \
  --dart-define=OPENAI_API_KEY=sk-XXXX \
  --dart-define=OPENAI_MODEL=gpt-4o-mini
```

Exemple build Release (OpenAI) – non recommandé pour partage public:
```bash
flutter build apk --release \
  --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions \
  --dart-define=OPENAI_API_KEY=sk-XXXX \
  --dart-define=OPENAI_MODEL=gpt-4o-mini
```


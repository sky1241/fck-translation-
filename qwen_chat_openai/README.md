# qwen_chat_openai

Chat FR ↔ ZH (zh-Hans) basé sur OpenAI Chat Completions (ChatGPT), UI type WhatsApp.

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


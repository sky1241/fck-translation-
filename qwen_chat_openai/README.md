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

## Fonctionnalités

- Traduction FR ⇄ ZH (zh-Hans) directionnelle avec ton (casual/affectionate/business)
- JSON strict côté sortie, fallback extraction {...}
- Persistance locale des messages (`shared_preferences`)
- UI type WhatsApp (texte, pinyin optionnel côté ZH)


# PROMPT CANONIQUE

Dernière mise à jour: 2025-10-05

Ce fichier conserve le prompt source fourni par l'utilisateur ainsi que la liste
des tâches à exécuter étape par étape pour limiter les erreurs et assurer la
traçabilité.

## Prompt courant

CURSOR/CODEDEX — BRIEF ULTIME (Flutter FR↔ZH + OpenAI, APK prêt)
Mission

Crée un projet Flutter (Dart 3.x, Flutter ≥3.22) de chat texte Français ⇄ Chinois simplifié (zh-Hans), traduction via OpenAI Chat Completions (endpoint OpenAI officiel).
Exigences : UI type WhatsApp, prompts directionnels (FR→ZH ≠ ZH→FR), JSON strict, stockage local, robustesse réseau, APK installable pour test direct sur téléphone (sans Play Store). Pas d’images, pas d’audio, pas de fichiers. 1) Arborescence à générer qwen_chat_openai/
  .gitignore
  README.md
  pubspec.yaml
  lib/
    app.dart
    main.dart
    core/
      env/app_env.dart           // lit --dart-define OPENAI_BASE_URL, OPENAI_API_KEY, OPENAI_MODEL
      json/json_utils.dart       // safeJsonDecode + extractFirstJson("{...}")
      network/http_client.dart   // http + timeouts + retries
    features/chat/
      data/
        models/chat_message.dart         // freezed/json_serializable
        models/translation_result.dart   // idem
        translation_service.dart         // OpenAI call + prompts
        chat_repository.dart
      domain/
        i_chat_repository.dart
      presentation/
        chat_page.dart
        chat_controller.dart             // Riverpod Notifier
        widgets/
          message_bubble.dart
          composer_bar.dart
  test/
    json_utils_test.dart
    translation_service_test.dart
  android/ …  ios/ … (par défaut Flutter)
2) Dépendances (pubspec.yaml)

http, shared_preferences, flutter_riverpod, freezed_annotation, json_annotation, intl, flutter_lints

Dev: build_runner, freezed, json_serializable, flutter_test

Activer flutter_lints et analysis_options.yaml avec implicit-casts: false, implicit-dynamic: false.

3) Config runtime (sécurité, pas de secrets committés)

Utiliser dart-define :

OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions

OPENAI_API_KEY=sk-xxx

OPENAI_MODEL=gpt-4o-mini (ou autre modèle chat compatible)

app_env.dart : class AppEnv {
  static const baseUrl = String.fromEnvironment('OPENAI_BASE_URL');
  static const apiKey  = String.fromEnvironment('OPENAI_API_KEY');
  static const model   = String.fromEnvironment('OPENAI_MODEL', defaultValue: 'gpt-4o-mini');
}
 4) Modèles (Freezed + JSON)

ChatMessage
id:String, originalText:String, translatedText:String, isMe:bool, time:DateTime, pinyin:String?, notes:String?

TranslationResult
translation:String, pinyin:String?, notes:String?

Générer les *.freezed.dart / *.g.dart.

5) Service de traduction (OpenAI)

TranslationService.translate({ text, sourceLang:'fr'|'zh', targetLang:'fr'|'zh', tone:'casual'|'affectionate'|'business', wantPinyin:bool })

POST → ${AppEnv.baseUrl}
Headers: Authorization: Bearer ${AppEnv.apiKey}, Content-Type: application/json

Body :

model: AppEnv.model

temperature: 0.2, max_tokens: 300

Si supporté : response_format: {"type":"json_object"}

messages = [ {"role":"system","content": SYSTEM_PROMPT}, {"role":"user","content": USER_PAYLOAD_JSON_STRING} ]

Robustesse : timeout 20s, 2 retries (backoff simple), parse via safeJsonDecode.
Lire choices[0].message.content (string) → doit être JSON strict. Si bruit autour, extractFirstJson("{...}") puis redécoder. En cas d’échec, lever une exception claire.

SYSTEM_PROMPT (utiliser exactement) You are a live dialogue translator for FR↔ZH ONLY (French ⇄ Chinese Simplified).
Never use or output any other language.
CRITICAL RULES:
1) Translate faithfully, but make target text idiomatic and natural for casual messaging (WeChat/WhatsApp).
2) Apply requested TONE (casual/affectionate/business).
3) Preserve emojis; avoid vulgarity unless explicitly present.
4) TARGET=Chinese: use Simplified Chinese (zh-Hans). If French is blunt, gently soften with polite mitigations (委婉) while keeping the original intent. Provide pinyin ONLY if requested.
5) TARGET=French: idiomatic, concise, emotionally clear; default tutoiement in romance, vouvoiement in business unless explicitly stated otherwise.
6) Do NOT add facts or change intent; no moralizing/safety boilerplate.
7) OUTPUT STRICT JSON ONLY (no markdown):
   {"translation": string, "pinyin": string|null, "notes": string|null}.
8) If input contains other languages, treat them as quoted content and translate only the FR↔ZH parts.
 USER_PAYLOAD_JSON (stringifié côté app à chaque envoi)

Échantillon (l’app remplace dynamiquement source_lang/target_lang/tone/want_pinyin/text) : {
  "task": "translate_dialogue",
  "source_lang": "fr",
  "target_lang": "zh",
  "tone": "casual",
  "want_pinyin": true,
  "roles": {
    "source_profile": "French male, casual Swiss-FR texting style; may be direct or teasing.",
    "target_profile": "Chinese output should be zh-Hans, smooth for WeChat; mitigate bluntness, keep affection natural."
  },
  "text": "Dors bien mon cœur, on parle demain. ❤️",
  "few_shot_examples": [
    {"source_lang":"fr","target_lang":"zh","tone":"affectionate","text":"Dors bien mon cœur, on parle demain. ❤️"},
    {"source_lang":"zh","target_lang":"fr","tone":"casual","text":"累坏了，我先去躺会儿，回头再聊。"}
  ],
  "constraints": {
    "preserve_emojis": true,
    "respect_intent": true,
    "avoid_overliteral": true,
    "style": "wechat_whatsapp",
    "json_only": true
  }
}
 6) Repository + contrôleur

IChatRepository → Future<TranslationResult> translate(...)

ChatRepository → appelle TranslationService

ChatController (Riverpod Notifier) :

État = List<ChatMessage>

send(text) : ajoute message, appelle traduction, ajoute message traduit, gère erreurs, persiste

swapDirection(), setTone(), togglePinyin()

7) Stockage local

shared_preferences

Clé: qwen_chat_messages_v1

loadMessages() au démarrage, saveMessages() après ajout/clear

Bouton “Effacer la conversation” dans l’AppBar

8) UI (WhatsApp-like, texte seulement)

ChatPage :

AppBar: titre FR → ZH / ZH → FR, bouton swap, bouton clear

Barre d’options: Dropdown tone (casual/affectionate/business), Switch pinyin (visible seulement si cible = zh)

ListView bulles :

original (italique, petit)

translation (16sp)

pinyin (12sp) si présent

notes (12sp) si présent

ComposerBar: TextField + bouton envoyer (désactivé si vide / en cours). Spinner durant l’appel.

Placeholders: source=fr → “Écrire en français…”, source=zh → “用中文输入…”

Langues strictes : n’autoriser que fr→zh ou zh→fr. Sinon, SnackBar “Langues supportées: FR ⇄ ZH uniquement.”

9) Tests minimum

json_utils_test.dart: safeJsonDecode, extractFirstJson

translation_service_test.dart: mock http → cas JSON propre, JSON bruité, HTTP 4xx/5xx

Vérifier translation/pinyin/notes

10) README minimal (générer)

Description, dépendances, configuration et exécution : flutter pub get
flutter run --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions \
            --dart-define=OPENAI_API_KEY=sk-XXXX \
            --dart-define=OPENAI_MODEL=gpt-4o-mini
 flutter pub get
flutter run --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions \
            --dart-define=OPENAI_API_KEY=sk-XXXX \
            --dart-define=OPENAI_MODEL=gpt-4o-mini
             --dart-define=OPENAI_MODEL=gpt-4o-mini

Build APK (pour test direct par lien) : flutter build apk --release
 11) Critères d’acceptation (bloquants)

flutter analyze OK, build OK, tests OK

Aucune duplication de fonctions de prompt

Direction FR↔ZH strictement respectée

Sortie JSON strict ; fallback extraction {...} opérationnel

Stockage local OK, clear OK

APK release générable et installable

Génère maintenant l’intégralité du code, les fichiers et le README, strictement selon 1→11.

Après génération (à faire côté toi)

Lancer avec tes --dart-define OpenAI.

Tester sur ton téléphone (USB ou APK).

Si tu veux, on fera ensuite des “micro-prompts” pour peaufiner champ par champ (couleurs, pinyin par défaut, etc.).

## Checklist d'exécution (étape par étape)

- [ ] 1) Générer squelette Flutter `qwen_chat_openai` (android/ios)
- [ ] 2) Ajouter `.gitignore`, `README.md`, `pubspec.yaml`, `analysis_options.yaml`
- [ ] 3) Implémenter `core` (env/json/http) + timeouts/retries
- [ ] 4) Créer modèles `ChatMessage`, `TranslationResult` (Freezed/JSON) + build
- [ ] 5) Écrire `TranslationService` (OpenAI, prompts, JSON strict, fallback)
- [ ] 6) Écrire `IChatRepository` + `ChatRepository`
- [ ] 7) Écrire `ChatController` (Riverpod) + persistance
- [ ] 8) UI `ChatPage` + widgets (WhatsApp-like) + actions
- [ ] 9) Persistance `shared_preferences` + bouton Clear
- [ ] 10) Tests `json_utils` et `translation_service` (mock HTTP)
- [ ] 11) README exécution + build APK

## Historique d'exécution (daté)

- 2025-10-05: Fichier initial créé, en attente du prompt utilisateur.
- 2025-10-05: Prompt utilisateur intégré, checklist créée.



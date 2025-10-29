## Présentation du projet

Objectif
- Échanger en temps réel FR ↔ ZH avec traduction idiomatique et pinyin optionnel.

Architecture
- Flutter (Android/Web) + Riverpod + Freezed/JSON.
- TranslationService → OpenAI Chat Completions (JSON strict).
- RealtimeService → WebSocket relay (rooms) pour synchroniser deux clients.

Points différenciants
- Prompt orienté conversation, contraintes de style (WeChat/WhatsApp), JSON strict.
- Résilience réseau (timeouts, retries, 429), fallback JSON.
- Paramétrage compile-time pour lancer 2 instances cohérentes (directions différentes).

Compétences acquises
- Multi-plateformes Flutter, injection de config par `--dart-define`.
- Conception de prompts robustes, traitement JSON strict.
- Réseau: http avec backoff/jitter, WebSocket relay minimaliste.

Améliorations possibles
- Plus d’exemples few-shot et tonalités.
- Migration Riverpod 3 / Freezed 3.
- UI: accusés de réception, indication de langue, latence.



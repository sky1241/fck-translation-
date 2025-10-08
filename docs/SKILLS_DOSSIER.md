## Dossier de compétences (session du 2025-10-06)

Résumé rapide
- Mise en place d’une app Flutter FR ↔ ZH type messagerie (Android + Web).
- Intégration OpenAI Chat Completions pour traduction bidirectionnelle.
- Synchronisation temps réel via WebSocket relay (Edge ↔ Android).

Compétences techniques
- Flutter multi-plateformes: Android et Web (Edge), debug et run ciblé.
- Gestion de configuration runtime: `--dart-define` (API key, modèle, direction, ton, pinyin).
- Architecture Flutter propre: Riverpod (state), Freezed/JSON (modèles), séparation data/domain/presentation.
- Réseau HTTP résilient: timeouts, retries exponentiels avec jitter, gestion 429/quota.
- Parsing JSON strict et fallback: extraction du premier objet `{...}` si nécessaire.
- WebSocket: conception d’un relay minimal (rooms), écoute/broadcast, prévention des boucles d’écho.
- Sécurité dev: non-commit des secrets, `.gitignore`, variables d’environnement.
- Tooling: script PowerShell d’orchestration multi-devices, `adb reverse` (debug), scrcpy, CI GitHub Actions.
- Badging & notifications: incrément non‑lus, remise à zéro, injection du nombre dans la notification (Android).
- Realtime paramétrable: RealtimeService (URL/room injectés), guide de connexion LAN/10.0.2.2/wss.
- Documentation: rapport journalier, présentation projet, README enrichi.

Compétences méthodologiques
- Débogage multi-environnements (Windows, Android, navigateur).
- Itérations rapides avec garde-fous (linting, gestion d’erreurs, logs). 
- Conception de prompts clairs orientés sortie JSON stricte et style conversationnel.
- Mise en place d’un flux temps réel stable (appairage des directions FR→ZH / ZH→FR).

Ce que tu peux revendiquer
- Savoir lancer, configurer et tester une app Flutter sur téléphone + navigateur.
- Savoir intégrer une API LLM (OpenAI) pour traduction en temps réel avec contraintes.
- Savoir synchroniser deux clients via WebSocket et équilibrer les directions de traduction.
- Savoir sécuriser les secrets en développement et préparer un dépôt Git propre.

Pistes d’amélioration
- Monter les dépendances (Riverpod 3, Freezed 3, analyzer 8) après audit.
- Ajouter des exemples few-shot supplémentaires et réglages de ton/contextes.
- Ajouter accusés de réception et meilleure gestion d’état du relay.
 - Héberger un relay wss public et figer RELAY_WS_URL/ROOM dans la release “no‑touch”.

Date: 2025-10-06

Résumé des travaux
- Paramétrage compile-time (direction/tone/pinyin) via AppEnv + --dart-define
- Intégration TranslationService (OpenAI Chat Completions), robustesse JSON
- Relay WebSocket minimal + intégration (Edge ↔ Android) sans boucles d’écho
- Script PowerShell de lancement multi-instances
- Sécurisation des secrets et docs d’exécution

Problèmes/risques notables
- Windows Desktop nécessite Developer Mode (plugins)
- Émulateur Android absent (SDK non configuré) → téléphone + Edge utilisé
- Dépendances avec mises à jour majeures planifiées

Prochaines étapes
- Audit / montée de version (Riverpod 3, Freezed 3, analyzer 8)
- Renforcement prompt (plus d’exemples few-shot) et options ton/contextes
- Ajout d’accusés de réception et rooms multiples si besoin



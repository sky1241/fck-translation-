Date: 2025-10-08

Résumé des actions
- Tentatives de lancement d’émulateurs Android Studio (API 30/35) en mode compatibilité (GPU off/ANGLE/SwiftShader), gestion ADB, et essais BlueStacks/MEmu; instabilité GPU côté machine locale.
- Installation et usage de scrcpy (miroir téléphone) pour valider notifications et flux temps réel sans émulateur.
- Badges/notifications: renforcement du comptage non‑lus (BadgeService) et injection du nombre dans AndroidNotificationDetails (number + channelShowBadge=true). Remise à zéro du badge à l’ouverture du chat.
- Realtime: RealtimeService refactor pour accepter (url, room) explicitement; guide de connexion ajouté.
- Démarrage/explication d’une liaison stable: documentation pour RELAY_WS_URL/ROOM (LAN vs 10.0.2.2 vs wss cloud) et conditions de visibilité réseau.
- CI: ajout d’un workflow GitHub Actions avec working-directory correct (qwen_chat_openai).

Décisions/points clés
- L’ANR «System UI isn’t responding» observé côté émulateur provient de la pile graphique/driver (pas du code Flutter). Tests conseillés: API 28/30, GPU off, cold boot, RAM 2 Go.
- Pour une release “plug-and-play”, héberger le relay en wss public et figer RELAY_WS_URL/ROOM dans le build.

Prochaines étapes
- Option A (recommandé): déployer un relay wss public, builder l’APK release avec URL/room figés et fournir lien d’installation.
- Option B: exposer des champs “Paramètres → Relay” dans l’app si besoin de flexibilité.

Fichiers/sections impactés aujourd’hui
- lib/core/network/notification_service_mobile.dart (badge number + showBadge)
- lib/core/network/badge_service.dart (expose currentCount)
- lib/core/network/realtime_service.dart (ctor url/room)
- lib/app.dart (dédup init notifs)
- docs/CONNECTION_AND_RELEASE_GUIDE.md (nouveau)
- .github/workflows/flutter-ci.yml (nouveau)



# Configuration du Badge de Notification (Point Rouge comme WhatsApp)

## 📅 Date de modification
**16 Octobre 2025**

## ✅ Configuration Terminée

Le badge de notification visuel (point rouge sur l'icône de l'application) a été configuré avec succès.

### Modifications apportées

#### 1. **Ajout du package `flutter_app_badger`**
```yaml
flutter_app_badger: ^1.5.0
```

#### 2. **Mise à jour du BadgeService**
Le service gère maintenant :
- ✅ Affichage du nombre de messages non lus sur l'icône de l'app
- ✅ Incrémentation automatique à chaque message reçu
- ✅ Réinitialisation quand l'utilisateur ouvre le chat
- ✅ Gestion des erreurs si le launcher ne supporte pas les badges

### Fonctionnement

```dart
// Message reçu → badge +1
await BadgeService.increment();  // 🔴 Point rouge avec chiffre

// Ouverture du chat → badge effacé
await BadgeService.clear();  // ✨ Plus de badge
```

### Support par Launcher Android

⚠️ **Important** : Le badge visuel sur l'icône dépend du launcher Android :

| Launcher | Support Badge | Note |
|----------|--------------|------|
| Samsung One UI | ✅ Oui | Support natif complet |
| Xiaomi MIUI | ✅ Oui | Support natif |
| OnePlus OxygenOS | ✅ Oui | Support natif |
| Google Pixel Launcher | ✅ Oui | Support natif (Android 8+) |
| Huawei EMUI | ✅ Oui | Nécessite permission spéciale |
| Nova Launcher | ✅ Oui | Avec extension TeslaUnread |
| Launcher standard AOSP | ⚠️ Partiel | Dépend de la version Android |

### Installation et Test

1. **Récupérer les dépendances** :
```bash
cd qwen_chat_openai
flutter pub get
```

2. **Rebuild l'application** :
```bash
flutter build apk --release
```

3. **Tester le badge** :
   - Installer l'APK
   - Envoyer un message via le relay WebSocket
   - Fermer l'app (ne pas la kill, juste minimiser)
   - Le badge devrait apparaître sur l'icône 🔴

### Intégration avec les Notifications

Le badge fonctionne en tandem avec les notifications :
```dart
// 1. Notification push
await _notif.showIncomingMessage(title: '...', body: '...');

// 2. Badge +1 automatique
await BadgeService.increment();

// 3. Ouverture du chat → badge clear
await BadgeService.clear();
```

### Code Source Principal

**`lib/core/network/badge_service.dart`** :
- Gestion du compteur de messages non lus
- Interface avec `flutter_app_badger`
- Gestion des erreurs et compatibilité

**`lib/features/chat/presentation/chat_page.dart`** (ligne 37) :
- Efface le badge à l'ouverture du chat

**`lib/features/chat/presentation/chat_controller.dart`** (lignes 81, 113) :
- Incrémente le badge à chaque message entrant

### Limitations Connues

1. **Launchers non supportés** : Certains launchers personnalisés ne supportent pas les badges
2. **Permissions spéciales** : Sur Huawei/Xiaomi, l'utilisateur doit parfois activer manuellement les badges dans les paramètres
3. **Android < 8.0** : Support limité ou inexistant

### Dépannage

**Le badge n'apparaît pas ?**
1. Vérifier le launcher utilisé
2. Aller dans Paramètres → Apps → XiaoXin002 → Notifications → Activer badges
3. Sur MIUI/EMUI : Activer "Afficher les badges" dans les paramètres de l'app

**Le badge ne s'efface pas ?**
- Redémarrer l'application
- Vérifier les logs : `flutter logs | grep -i badge`

---

## 🎯 Résultat Final

L'application affiche maintenant un point rouge avec le nombre de messages non lus sur son icône, exactement comme WhatsApp ! 🔴



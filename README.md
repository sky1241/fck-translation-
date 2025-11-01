# 📱 XiaoXin - Application de Traduction en Temps Réel

Application Flutter Android permettant une communication bilingue (FR↔ZH) en temps réel avec traduction automatique.

## 🎯 Description

Deux applications Android distinctes :
- **XiaoXin 001 (TOI)** : Interface en français, traduit FR→ZH
- **XiaoXin 002 (ELLE)** : Interface en chinois, traduit ZH→FR

## 🚀 Installation

### Prérequis
- Flutter SDK (latest stable)
- Android SDK
- PowerShell (pour les scripts de build)

### Build des APKs
```powershell
.\BUILD_RELEASE_COMPLET.ps1
```

Les APKs seront générées dans le dossier parent :
- `XiaoXin-001-RELEASE.apk` (TOI - FR→ZH)
- `XiaoXin-002-RELEASE.apk` (ELLE - ZH→FR)

### Installation
```powershell
# Téléphone
adb -s <device_id> install "..\XiaoXin-001-RELEASE.apk"

# Émulateur
adb -s emulator-5554 install "..\XiaoXin-002-RELEASE.apk"
```

## 📋 Fonctionnalités

- ✅ Communication en temps réel via WebSocket
- ✅ Traduction automatique (OpenAI GPT-4o-mini)
- ✅ Envoi de photos/vidéos
- ✅ Enregistrement audio
- ✅ Galerie de photos partagées
- ✅ Badge notifications
- ✅ Messages texte formatés

## 🧪 Tests

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
```

## 📚 Documentation Complète

Consultez [PROJET_COMPLET_FIVERR.md](PROJET_COMPLET_FIVERR.md) pour :
- Architecture détaillée
- Problèmes rencontrés et solutions
- Leçons apprises
- Commandes utiles
- Statistiques du projet

## 🛠️ Technologies

- Flutter/Dart
- Riverpod (state management)
- WebSocket (communication temps réel)
- OpenAI API (traduction)
- Kotlin (code natif Android)

## 📄 Licence

Propriétaire - Tous droits réservés

---

**Développé pour Fiverr - 2025**

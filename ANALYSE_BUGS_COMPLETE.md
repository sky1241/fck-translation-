# 🔍 ANALYSE COMPLÈTE DES BUGS - 2025-01-27

## ❌ BUG #1 : Photos ne se sauvegardent PAS dans la galerie

### Problème identifié :
- Quand on ENVOIE une photo via `_sendAttachmentDraft()`, elle n'est jamais ajoutée au PhotoRepository
- Quand on REÇOIT une photo via `_receiveRemote()` pour attachment, elle n'est jamais ajoutée au PhotoRepository
- La galerie (PhotoGalleryPage) lit uniquement depuis PhotoRepository, donc les photos envoyées/reçues n'apparaissent jamais

### Solution :
- Appeler `PhotoRepository.savePhoto()` quand on envoie une photo (avec isFromMe=true)
- Appeler `PhotoRepository.savePhoto()` quand on reçoit une photo (avec isFromMe=false)
- Créer un PhotoGalleryItem à partir de l'Attachment

---

## ❌ BUG #2 : Enregistrement audio freeze l'application

### Problème identifié :
- Dans `stopRecordingVoice()`, on appelle `_picker.pickFile(path)` ce qui n'a pas de sens
- `pickFile()` attend probablement une sélection utilisateur, ce qui freeze l'app
- Le path retourné par `stopRecording()` devrait être directement utilisé

### Solution :
- Supprimer l'appel à `pickFile()`
- Utiliser directement le path retourné par `stopRecording()`
- Créer un AttachmentDraft directement depuis le fichier audio

---

## 📋 TODO - Corrections à faire

1. ✅ Ajouter PhotoRepository dans ChatController
2. ✅ Sauvegarder photo envoyée dans la galerie
3. ✅ Sauvegarder photo reçue dans la galerie
4. ✅ Corriger stopRecordingVoice() pour ne pas freeze
5. ✅ Tester et vérifier GitHub Actions


# 🧪 Test de Connexion Temps Réel

## ✅ État Actuel

- 📱 **Téléphone Xiaomi** (FMMFSOOBXO8T5D75) : ✅ App lancée
- 💻 **Émulateur Android Studio** (emulator-5554 - API30) : ✅ App lancée
- 🌐 **WebSocket Relay** : wss://fck-relay-ws.onrender.com (room: demo123)

---

## 🧪 Protocole de Test

### Test 1 : Téléphone → Émulateur

1. **Sur ton TÉLÉPHONE** :
   - Ouvre l'app XiaoXin002 (déjà lancée)
   - Écris un message en **français** : `"Bonjour"`
   - Appuie sur **Envoyer** (flèche)

2. **Sur l'ÉMULATEUR** (dans Android Studio) :
   - Tu devrais voir apparaître : `"你好"` (traduction en chinois)
   - **Délai attendu** : 2-5 secondes

✅ **Si ça marche** → La sync téléphone→émulateur est OK !

---

### Test 2 : Émulateur → Téléphone

1. **Sur l'ÉMULATEUR** :
   - Écris un message en **chinois** : `"想你"` (ou copie-colle depuis ce doc)
   - Appuie sur **Envoyer**

2. **Sur ton TÉLÉPHONE** :
   - Tu devrais voir apparaître : `"Tu me manques"`
   - **Délai attendu** : 2-5 secondes

✅ **Si ça marche** → La sync émulateur→téléphone est OK !

---

### Test 3 : Messages Multiples (Spam Test)

1. Envoie **3 messages rapides** depuis le téléphone :
   - "Je t'aime"
   - "Tu me manques"
   - "À bientôt"

2. Vérifie que l'émulateur reçoit **les 3 traductions** :
   - "我爱你"
   - "想你了"
   - "待会儿见"

✅ **Si ça marche** → La sync multiple est OK !

---

### Test 4 : Direction Auto (Détection Langue)

1. **Sur le TÉLÉPHONE**, écris en **français** : `"Salut"`
   - Devrait traduire en chinois : `"你好"`

2. **Sur le TÉLÉPHONE**, écris en **chinois** : `"谢谢"`
   - Devrait traduire en français : `"Merci"`

✅ **Si ça marche** → La détection automatique fonctionne !

---

## 🔍 Vérification de Connexion WebSocket

Pour voir les logs en temps réel :

```powershell
# Logs du téléphone
adb -s FMMFSOOBXO8T5D75 logcat | Select-String -Pattern "WebSocket|flutter"

# Logs de l'émulateur
adb -s emulator-5554 logcat | Select-String -Pattern "WebSocket|flutter"
```

**Messages attendus** :
- `Connected to WebSocket`
- `Received message from relay`
- `Sending message to relay`

---

## ⚠️ Problèmes Possibles

### Problème 1 : Messages ne passent pas

**Causes possibles** :
- WebSocket relay offline (Render.com en sommeil)
- Pas de connexion internet
- Firewall bloque wss://

**Solution** :
```powershell
# Vérifier la connexion au relay
curl https://fck-relay-ws.onrender.com
```

Si erreur → Attends 30 secondes (Render.com se réveille)

---

### Problème 2 : Traduction ne fonctionne pas

**Causes possibles** :
- Clé API OpenAI invalide
- Quota OpenAI dépassé

**Solution** :
- Vérifie les logs : `adb logcat | Select-String "OpenAI|error"`
- Vérifie le dashboard OpenAI : https://platform.openai.com/usage

---

### Problème 3 : App crash

**Solution** :
```powershell
# Force restart
adb -s FMMFSOOBXO8T5D75 shell am force-stop com.example.qwen_chat_openai
adb -s FMMFSOOBXO8T5D75 shell am start -n com.example.qwen_chat_openai/.MainActivity
```

---

## ✅ Checklist de Validation

Avant de partager l'APK avec ta copine, vérifie :

- [ ] Test 1 : Téléphone → Émulateur ✅
- [ ] Test 2 : Émulateur → Téléphone ✅
- [ ] Test 3 : Messages multiples ✅
- [ ] Test 4 : Détection auto langue ✅
- [ ] Traductions correctes (français ↔ chinois) ✅
- [ ] Délai acceptable (< 5 secondes) ✅
- [ ] Aucun crash ✅
- [ ] Notifications fonctionnent ✅

---

## 🎯 Résultat Attendu

**Scénario idéal** :
1. Tu écris "Je t'aime" sur ton téléphone
2. L'émulateur reçoit "我爱你" en 2-3 secondes
3. L'émulateur écrit "想你"
4. Ton téléphone reçoit "Tu me manques" en 2-3 secondes

✅ **Si tout ça marche** → L'app est prête pour ta copine !

---

## 📝 Notes

- **Room WebSocket** : `demo123` (même room pour tous les utilisateurs actuellement)
- **Direction par défaut** : `fr2zh` (français → chinois)
- **Tone** : `affectionate` (ton affectueux)
- **Pinyin** : `true` (affiche la prononciation)

---

**Fait le test maintenant et dis-moi si ça marche ! 🚀**


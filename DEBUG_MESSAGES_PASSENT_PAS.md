# 🔍 DEBUG - Messages Ne Passent Pas d'Un Côté

## 🚨 PROBLÈME ACTUEL

- ✅ **TOI** → Tu reçois ses messages
- ❌ **ELLE** → Elle ne reçoit PAS tes messages

---

## 🔍 DIAGNOSTIC RAPIDE

### Check 1 : Vérifier la Connexion WebSocket

**Sur SON téléphone** :

1. Ouvre l'app
2. Regarde en haut de l'écran
3. Y a-t-il un **point vert** ou un indicateur de connexion ?

**Si NON** → Son app n'est pas connectée au relay

---

### Check 2 : Vérifier la Room

Les 2 apps doivent être dans la **même room** : `demo123`

**Vérification** :
- Les 2 apps ont été buildées avec les mêmes paramètres ?
- `--dart-define=RELAY_ROOM=demo123`

**Si DIFFÉRENTES** → Vous êtes dans 2 rooms différentes, les messages ne passent pas

---

### Check 3 : Vérifier la Connexion Internet

**Sur SON téléphone** :

1. Ouvre un navigateur
2. Va sur Google ou n'importe quel site
3. Ça marche ?

**Si NON** → Pas de connexion internet → Pas de WebSocket

---

### Check 4 : Forcer la Reconnexion

**Sur SON téléphone** :

1. **Ferme complètement l'app** (pas juste minimiser)
   - Paramètres → Apps → XiaoXin002 → Forcer l'arrêt
   - Ou : Menu multitâche → Glisse l'app vers le haut

2. **Réouvre l'app**

3. Attends 5 secondes (connexion WebSocket)

4. **Réessaie d'envoyer un message**

---

## 🧪 TEST DE DIAGNOSTIC

### Test 1 : Toi → Elle (NE MARCHE PAS actuellement)

**TOI** : Envoie "test 1"  
**ELLE** : Devrait recevoir (mais ne reçoit pas)

### Test 2 : Elle → Toi (MARCHE)

**ELLE** : Envoie "test 2"  
**TOI** : Tu reçois ✅

---

## 💡 SOLUTION PROBABLE

### Problème : WebSocket pas connecté de son côté

**Solution 1 : Force Stop + Redémarrage**

Sur SON téléphone :
1. Paramètres → Apps → XiaoXin002
2. **"Forcer l'arrêt"**
3. Retourne à l'écran d'accueil
4. **Ouvre l'app** à nouveau
5. Attends 5 secondes
6. **Réessaie d'envoyer**

---

**Solution 2 : Vérifier le Relay Render.com**

Le relay WebSocket (`wss://fck-relay-ws.onrender.com`) peut être en sommeil.

**Attends 30 secondes** et réessaie.

Le premier message peut être lent (Render.com se réveille), les suivants seront rapides.

---

**Solution 3 : Vérifier les Permissions**

Sur SON téléphone :
1. Paramètres → Apps → XiaoXin002
2. Vérifier **"Autostart"** (démarrage automatique) → **ACTIVÉ**
3. Vérifier **"Données mobiles"** → **ACTIVÉ**
4. Vérifier **"WiFi"** → **ACTIVÉ**
5. Vérifier **"Exécution en arrière-plan"** → **ACTIVÉ**

Sur Xiaomi MIUI :
- Paramètres → Apps → Gérer les apps → XiaoXin002
- **Autostart** → ON
- **Économie d'énergie** → Pas de restrictions
- **Données** → WiFi et Données mobiles autorisés

---

## 🔧 SOLUTION TECHNIQUE (Si tout le reste échoue)

### Réinstallation Propre

**Sur SON téléphone** :

1. **Désinstalle complètement** l'app
2. **Redémarre le téléphone**
3. **Réinstalle** l'APK
4. **Ouvre l'app**
5. **Autorise les notifications**
6. **Attends 10 secondes** (connexion au relay)
7. **Réessaie**

---

## 🧪 TEST SIMPLE POUR CONFIRMER

### Étape 1 : Elle Force Stop
- Paramètres → Apps → XiaoXin002 → Forcer l'arrêt

### Étape 2 : Elle Réouvre l'App
- Ouvre XiaoXin002 depuis l'icône

### Étape 3 : Attends 5 Secondes
- Le WebSocket se connecte

### Étape 4 : TOI → Envoie "hello"
- Elle devrait recevoir "你好"

### Étape 5 : ELLE → Envoie "想你"
- Tu devrais recevoir "Tu me manques"

---

## ⚡ SOLUTION RAPIDE (TL;DR)

**Sur SON téléphone** :
1. Force Stop l'app (Paramètres → Apps → Forcer l'arrêt)
2. Réouvre l'app
3. Attends 5 secondes
4. Réessaie d'envoyer

**Ça marche dans 90% des cas !**

---

## 🆘 SI ÇA MARCHE TOUJOURS PAS

**Dis-moi** :
1. Quel téléphone elle utilise ? (marque/modèle)
2. Version Android ? (Paramètres → À propos du téléphone)
3. Elle est en WiFi ou 4G ?
4. Elle a cliqué "Autoriser" pour les notifications ?

Je pourrai te donner une solution plus précise !

---

**Status** : 🟡 Debug en cours  
**Prochaine action** : Force Stop + Réouverture


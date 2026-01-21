# Test d'authentification - Vite & Gourmand

## Problème identifié ✅

**Erreur** : Toutes les requêtes retournent 401 "Token invalide"
**Cause** : Token expiré/invalide stocké dans SecureStorage, ou absence de token

## Solutions implémentées ✅

### 1. Nettoyage automatique du token sur 401
- **Fichier** : `lib/core/api/dio_client.dart`
- **Action** : L'intercepteur Dio efface automatiquement le token quand une réponse 401 est reçue
- **Log** : Affiche "🔑 Token invalide détecté, nettoyage du token"

### 2. Redirection automatique vers login sur 401
- **Fichiers modifiés** :
  - `lib/features/orders/orders_list_page.dart`
  - `lib/features/orders/order_tracking_page.dart`
  - `lib/features/orders/order_detail_page.dart`
  - `lib/features/settings/user_settings_page.dart`
- **Action** : Si une erreur 401 est détectée, redirection automatique vers la page de login

## Test de la correction 🧪

### Étape 1 : Redémarrer l'application
```bash
# Dans le terminal front
flutter run -d chrome
```

### Étape 2 : Effacer le token existant

**Option A - Via Chrome DevTools (Recommandé)**
1. Ouvrir Chrome DevTools (F12)
2. Aller dans "Application" > "Local Storage" ou "IndexedDB"
3. Chercher et supprimer la clé "access_token"
4. Recharger la page

**Option B - Hot Restart Flutter**
```bash
# Dans le terminal flutter, appuyer sur
R   # (Shift+R pour hot restart complet)
```

### Étape 3 : Tester le flux complet

1. **Splash Screen**
   - ✅ Devrait détecter l'absence de token
   - ✅ Devrait rediriger vers HomePage (page publique)

2. **Connexion**
   - Cliquer sur "Se connecter"
   - Entrer vos identifiants de test
   - ✅ Devrait sauvegarder le token
   - ✅ Devrait rediriger vers MainNavigationPage

3. **Navigation**
   - ✅ Tab "Commandes" devrait charger vos commandes
   - ✅ Tab "Suivi" devrait afficher la prochaine commande
   - ✅ Tab "Paramètres" devrait afficher votre profil

4. **Test d'expiration (optionnel)**
   - Modifier manuellement le token dans le storage pour le rendre invalide
   - Naviguer dans l'app
   - ✅ Devrait détecter le 401 et rediriger vers login automatiquement

## Résultat attendu ✅

- Aucune erreur 401 en boucle
- Redirection propre vers login si token invalide
- Connexion fonctionnelle avec sauvegarde du token
- Navigation fluide après connexion

## Commandes utiles

```bash
# Relancer le serveur API
cd vite-gourmand-api
uvicorn app.main:app --reload --port 8000

# Relancer le front Flutter
cd vite_gourmand_app
flutter run -d chrome

# Créer un compte de test via API
curl -X POST http://127.0.0.1:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!",
    "full_name": "Test User"
  }'

# Se connecter via API pour obtenir un token
curl -X POST http://127.0.0.1:8000/auth/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&username=test@example.com&password=Test123!"
```

## Si le problème persiste

### Vérifier que le token est bien envoyé

Dans les logs Flutter, chercher :
```
🌐 API: headers:
🌐 API:  Content-Type: application/json
🌐 API:  Accept: application/json
🌐 API:  Authorization: Bearer eyJ...  ← DOIT APPARAÎTRE
```

### Vérifier côté serveur

Dans les logs uvicorn, vérifier :
```
INFO:     127.0.0.1:xxxxx - "GET /orders/me HTTP/1.1" 200 OK  ← OK
```
(Pas 401)

### Déboguer le SecureStorage

Ajouter temporairement dans `_loadOrders()` :
```dart
final storage = SecureStorage();
final token = await storage.readToken();
print('🔑 Token stocké: ${token?.substring(0, 20)}...');
```

## Notes importantes 📝

- Le token est sauvegardé dans `flutter_secure_storage`
- Sur web, c'est stocké dans IndexedDB/LocalStorage du navigateur
- Un hot reload NE VIDE PAS le storage
- Un hot restart NE VIDE PAS non plus le storage
- Pour vraiment vider : nettoyer le cache du navigateur ou désinstaller l'app (mobile)

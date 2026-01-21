# Configuration Deep Link - Réinitialisation Mot de Passe

## Format des liens

### Pour les tests en développement (Android/iOS)
```
vitegourmand://reset-password?token=<JWT_TOKEN>
```

### Pour la production avec domaine web
```
https://votredomaine.com/reset-password?token=<JWT_TOKEN>
```

## Configuration Android
Le fichier `android/app/src/main/AndroidManifest.xml` a été configuré pour accepter les deep links avec le schéma `vitegourmand://`.

## Configuration iOS
Pour iOS, vous devez configurer le fichier `ios/Runner/Info.plist` avec les URL schemes (à faire manuellement).

## Backend - Génération du lien d'email

Dans `vite-gourmand-api/app/modules/email_service.py`, la fonction `send_password_reset_email()` doit générer le lien :

```python
# Pour développement
reset_link = f"vitegourmand://reset-password?token={reset_token}"

# Pour production avec domaine
reset_link = f"https://votredomaine.com/reset-password?token={reset_token}"
```

## Test du deep link

### Android
1. Construire et lancer l'app
2. Envoyer un email de réinitialisation
3. Cliquer sur le lien dans l'email
4. L'app doit s'ouvrir directement sur la page de réinitialisation

### Web
1. Lancer l'app web
2. Le deep link ne fonctionnera pas directement sur web
3. Alternative : passer le token via les query parameters de l'URL
   ```
   https://localhost:port/#/reset-password?token=xxx
   ```

## Modification du backend

Vous devez modifier la fonction `send_password_reset_email()` dans le backend pour utiliser le bon format de lien selon l'environnement.

**Fichier à modifier :** `vite-gourmand-api/app/modules/email_service.py`

```python
def send_password_reset_email(email: str, user_name: str, reset_token: str):
    """Envoie un email de réinitialisation de mot de passe"""
    
    # Choisir le format selon l'environnement
    # Pour développement mobile
    reset_link = f"vitegourmand://reset-password?token={reset_token}"
    
    # Pour production avec domaine
    # reset_link = f"https://votredomaine.com/reset-password?token={reset_token}"
    
    # Pour web uniquement
    # reset_link = f"http://localhost:8080/#/reset-password?token={reset_token}"
    
    # ... reste du code email
```

## URLs configurées

- **Mot de passe oublié (POST):** `/auth/forgot-password`
- **Réinitialisation (POST):** `/auth/reset-password`

## Flow complet

1. Utilisateur clique sur "Mot de passe oublié ?" dans l'app
2. Page ForgotPasswordPage demande l'email
3. Backend envoie un email avec le lien de réinitialisation
4. Utilisateur clique sur le lien dans l'email
5. L'app s'ouvre sur ResetPasswordPage avec le token
6. Utilisateur entre son nouveau mot de passe
7. Backend valide le token et met à jour le mot de passe
8. Utilisateur est redirigé vers la page de connexion

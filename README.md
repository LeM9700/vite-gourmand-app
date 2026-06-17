# Vite & Gourmand 🍽️

![Tests](https://github.com/LeM9700/vite-gourmand-app/workflows/Tests/badge.svg)
![Analyze](https://github.com/LeM9700/vite-gourmand-app/workflows/Analyze/badge.svg)
![Build](https://github.com/LeM9700/vite-gourmand-app/workflows/Build/badge.svg)
[![codecov](https://codecov.io/gh/LeM9700/vite-gourmand-app/branch/main/graph/badge.svg)](https://codecov.io/gh/LeM9700/vite-gourmand-app)

Application mobile/web de gestion de commandes traiteur haut de gamme.

## Prérequis
- Flutter SDK (aligné avec le projet / CI)
- Dart (inclus avec Flutter)
- (Optionnel) Chrome pour exécuter l’app en web
- (Pour E2E) Une API en local ou en production accessible

## 📦 Installation
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## ▶️ Lancer l’application
### Web
```bash
flutter run -d chrome
```

### Windows
```bash
flutter run -d windows
```

## 🔧 Configuration API
L’URL de l’API est configurée côté app dans `lib/core/config.dart` via `AppConfig.getApiUrl()`.

- Mode debug : `http://127.0.0.1:8000`
- Mode release : `https://vite-gourmand-api-production.up.railway.app`

Pour pointer vers une autre API, modifiez `AppConfig.getApiUrl()`.

## 🧪 Tests
```bash
# Tests unitaires + widgets
flutter test

# Tests d'intégration (nécessite Chrome + API accessible)
.\run_integration_tests.ps1
```

## 📊 Couverture de code
- Tests unitaires : **148 tests** ✅
- Tests widgets : **18 tests** ✅
- Tests E2E : **26 tests** ✅
- **Total : 192 tests**

## 🚀 CI/CD
Les workflows GitHub Actions s'exécutent automatiquement sur :
- ✅ Chaque push sur `main` ou `develop`
- ✅ Chaque Pull Request
- ✅ Tags de version (`v*`)

### Workflows disponibles
| Workflow | Déclencheur | Durée |
|----------|-------------|-------|
| **Tests** | Push/PR | ~5 min |
| **Analyze** | Push/PR | ~3 min |
| **Build** | Push main / Tag | ~20 min |

## 🏗️ Build manuel
```bash
# Web
flutter build web --profile

# Windows
flutter build windows --release
```

## 🔗 Liens
- API (Railway) : https://vite-gourmand-api-production.up.railway.app
- App (Netlify) : https://www.vitegourmand.netlify.app
- Backend repo : https://github.com/LeM9700/vite-gourmand-api
- Front repo : https://github.com/LeM9700/vite-gourmand-app

## 📱 Plateformes supportées
- ✅ Web (Chrome, Firefox, Safari)
- ✅ Windows
- ⚠️ Android (en développement)
- ⚠️ iOS (en développement)

## 🤝 Contribution
Voir [CONTRIBUTING.md](CONTRIBUTING.md) pour les guidelines.

## 📄 Licence
MIT

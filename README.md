# Vite & Gourmand 🍽️

![Tests](https://github.com/LeM9700/vite-gourmand-app/workflows/Tests/badge.svg)
![Analyze](https://github.com/LeM9700/vite-gourmand-app/workflows/Analyze/badge.svg)
![Build](https://github.com/LeM9700/vite-gourmand-app/workflows/Build/badge.svg)
[![codecov](https://codecov.io/gh/LeM9700/vite-gourmand-app/branch/main/graph/badge.svg)](https://codecov.io/gh/LeM9700/vite-gourmand-app)

Application mobile/web de gestion de commandes traiteur haut de gamme.

## 🧪 Tests

```bash
# Tests unitaires + widgets
flutter test

# Tests d'intégration (nécessite ChromeDriver + API)
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

## 📦 Installation

```bash
# Dépendances
flutter pub get

# Générer les modèles
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🔧 Configuration

Créez un fichier `.env` à la racine :

```env
API_BASE_URL=http://127.0.0.1:8000
```

## 📱 Plateformes supportées

- ✅ Web (Chrome, Firefox, Safari)
- ✅ Windows
- ⚠️ Android (en développement)
- ⚠️ iOS (en développement)

## 🤝 Contribution

Voir [CONTRIBUTING.md](CONTRIBUTING.md) pour les guidelines.

## 📄 Licence

MIT

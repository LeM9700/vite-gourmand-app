import 'package:flutter/foundation.dart';

class AppConfig {
  // ✅ Configuration selon la plateforme
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000', // ✅ IP locale pour tous
  );

  static const bool isDevelopment = true;

  // ✅ Méthode pour obtenir l'URL selon la plateforme
  // Configuration selon la plateforme
  static String getApiUrl() {
    if (kIsWeb) {
      // 🧪 Tests/Dev web : local / 🌐 Production web : Railway
      return kDebugMode
          ? 'http://127.0.0.1:8000' // Tests d'intégration web
          : 'https://vite-gourmand-api-production.up.railway.app'; // Production web
    } else {
      // 📱 Mobile/Desktop : Local ou production selon le mode
      return kDebugMode
          ? 'http://127.0.0.1:8000' // Développement local
          : 'https://vite-gourmand-api-production.up.railway.app'; // Production mobile
    }
  }

  // Autres configurations
  static const String appName = 'Vite & Gourmand';
  static const String version = '1.0.0';

  // URL pour les deep links
  static String getFrontendUrl() {
    if (kIsWeb) {
      return 'https://www.vitegourmand.netlify.app'; // URL web hébergée
    } else {
      return 'vitegourmand://'; // Deep link mobile
    }
  }
}

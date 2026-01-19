// lib/core/config.dart
class AppConfig {
  // ✅ Configuration selon la plateforme
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',  // ✅ IP locale pour tous
  );
  
  static const bool isDevelopment = true;
  
  // ✅ Méthode pour obtenir l'URL selon la plateforme
  static String getApiUrl() {
    // Pour le web, utilisez toujours localhost/127.0.0.1
    return 'http://127.0.0.1:8000';
  }
}
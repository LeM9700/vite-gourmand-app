import 'package:flutter_test/flutter_test.dart';
import 'package:vite_gourmand_app/core/storage/secure_storage.dart';

void main() {
  // NOTE: SecureStorage utilise FlutterSecureStorage qui necessite
  // des MethodChannels natifs non disponibles en tests unitaires.
  // Ces tests valident uniquement la structure sans execution.

  group('SecureStorage - Structure', () {
    // TEST 1: Vérifie que la classe SecureStorage peut être instanciée
    // sans erreur et retourne un objet non-null

    test('SecureStorage peut etre instancie', () {
      final storage = SecureStorage();
      expect(storage, isNotNull);
      expect(storage, isA<SecureStorage>());
    });

    // TEST 2: Vérifie que toutes les méthodes publiques existent
    // (sans les appeler, car cela nécessiterait les MethodChannels)

    test('SecureStorage a toutes les methodes requises', () {
      final storage = SecureStorage();

      // Verifier que toutes les methodes existent (sans les executer)
      expect(storage.saveToken, isA<Function>());
      expect(storage.readToken, isA<Function>());
      expect(storage.clearToken, isA<Function>());
      expect(storage.saveRole, isA<Function>());
      expect(storage.readRole, isA<Function>());
      expect(storage.clearRole, isA<Function>());
      expect(storage.clearAll, isA<Function>());
    });
  });
}

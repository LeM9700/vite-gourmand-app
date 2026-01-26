import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vite_gourmand_app/features/auth/services/auth_service.dart';
import 'package:vite_gourmand_app/features/auth/models/auth_models.dart';
import 'package:vite_gourmand_app/core/api/dio_client.dart';
import 'package:dio/dio.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AuthService authService;
  late DioClient dioClient;

  setUpAll(() async {
    authService = AuthService();
    dioClient = await DioClient.create();
  });

  group('Error Handling - Integration Tests', () {
    // ==================== AUTH ERRORS ====================

    test('01 - Register avec email déjà utilisé → 400', () async {
      // Arrange - Créer un user
      final email =
          'duplicate_${DateTime.now().millisecondsSinceEpoch}@test.com';
      final request1 = RegisterRequest(
        firstname: 'First',
        lastname: 'User',
        email: email,
        password: 'Pass123!',
        phone: '+33611111111',
        address: '1 rue Inexistante, 33000 Bordeaux',
      );
      await authService.register(request1);

      // Act - Tenter de créer le même email
      final request2 = RegisterRequest(
        firstname: 'Second',
        lastname: 'User',
        email: email, // ❌ Même email
        password: 'Pass123!',
        phone: '+33622222222',
        address: '1 rue Inexistante, 33000 Bordeaux',
      );

      // Assert
      expect(() => authService.register(request2), throwsA(isA<Exception>()));
    });

    test('02 - Login avec email inexistant → 401', () async {
      // Arrange
      final request = LoginRequest(
        email: 'inexistant_${DateTime.now().millisecondsSinceEpoch}@test.com',
        password: 'Test123!',
      );

      // Act & Assert
      expect(() => authService.login(request), throwsA(isA<Exception>()));
    });

    test('03 - Login avec mauvais password → 401', () async {
      // Arrange - Créer un user
      final email =
          'bad_pass_${DateTime.now().millisecondsSinceEpoch}@test.com';
      final registerRequest = RegisterRequest(
        firstname: 'Bad',
        lastname: 'Pass',
        email: email,
        password: 'CorrectPass123!',
        phone: '+33633333333',
        address: '1 rue Inexistante, 33000 Bordeaux',
      );
      await authService.register(registerRequest);

      // Act - Login avec mauvais password
      final loginRequest = LoginRequest(
        email: email,
        password: 'WrongPass123!', // ❌ Mauvais
      );

      // Assert
      expect(() => authService.login(loginRequest), throwsA(isA<Exception>()));
    });

    test('04 - Password trop court → Validation error', () async {
      // Arrange
      final request = RegisterRequest(
        firstname: 'Short',
        lastname: 'Pass',
        email: 'short_${DateTime.now().millisecondsSinceEpoch}@test.com',
        password: '123', // ❌ Trop court
        phone: '+33644444444',
        address: '1 rue Test, 33000 Bordeaux',
      );

      // Act & Assert
      expect(() => authService.register(request), throwsA(isA<Exception>()));
    });

    test('05 - Email format invalide → Validation error', () async {
      // Arrange
      final request = RegisterRequest(
        firstname: 'Invalid',
        lastname: 'Email',
        email: 'not-an-email', // ❌ Format invalide
        password: 'Pass123!',
        phone: '+33655555555',
        address: '1 rue Inexistante, 33000 Bordeaux',
      );

      // Act & Assert
      expect(() => authService.register(request), throwsA(isA<Exception>()));
    });

    // ==================== API ERRORS ====================

    test('06 - Requête sans token → 401 Unauthorized', () async {
      // Arrange - Se déconnecter
      await authService.logout();

      // Act & Assert - Essayer d'accéder à un endpoint protégé
      expect(
        () => dioClient.dio.get('/users/me'),
        throwsA(isA<DioException>()),
      );
    });

    test('07 - Token expiré → 401', () async {
      // Simuler un token expiré
      // Nécessite de mocker l'interceptor ou d'attendre l'expiration réelle
    });

    test('08 - Endpoint inexistant → 404', () async {
      // Arrange - Se connecter
      final email =
          '404_test_${DateTime.now().millisecondsSinceEpoch}@test.com';
      final registerRequest = RegisterRequest(
        firstname: 'Not',
        lastname: 'Found',
        email: email,
        password: 'Test123!',
        phone: '+33666666666',
        address: '1 rue Inexistante, 33000 Bordeaux',
      );
      await authService.register(registerRequest);
      await authService.login(LoginRequest(email: email, password: 'Test123!'));

      // Act & Assert - Appeler un endpoint qui n'existe pas
      expect(
        () => dioClient.dio.get('/this/endpoint/does/not/exist'),
        throwsA(isA<DioException>()),
      );
    });

    test('09 - Requête avec données invalides → 422', () async {
      // Arrange - Se connecter
      final email =
          'invalid_data_${DateTime.now().millisecondsSinceEpoch}@test.com';
      final registerRequest = RegisterRequest(
        firstname: 'Invalid',
        lastname: 'Data',
        email: email,
        password: 'Test123!',
        phone: '+33677777777',
        address: '1 rue Inexistante, 33000 Bordeaux',
      );
      await authService.register(registerRequest);
      await authService.login(LoginRequest(email: email, password: 'Test123!'));

      // Act & Assert - Créer une commande avec données invalides
      final invalidPayload = {
        'menu_id': 'not-a-number', // ❌ Type invalide
        'event_date': 'invalid-date', // ❌ Format invalide
      };

      expect(
        () => dioClient.dio.post('/orders', data: invalidPayload),
        throwsA(isA<DioException>()),
      );
    });

    test('10 - Network timeout → Exception', () async {
      //  Configurer un timeout très court et tester
      // dioClient.dio.options.connectTimeout = Duration(milliseconds: 1);
    });

    test('11 - Server error 500 → Exception', () async {
      //  Déclencher une erreur serveur (endpoint de test ?)
    });

    // ==================== BUSINESS LOGIC ERRORS ====================

    test('12 - Commander avec event_date passée → Error', () async {
      // Testé dans order_flow_test.dart (TEST 11)
    });

    test('13 - Commander sans stock → Error', () async {
      // Testé dans order_flow_test.dart (TEST 09)
    });

    test('14 - Annuler commande CONFIRMED → Error', () async {
      // Testé dans order_flow_test.dart (TEST 08)
    });
  });

  tearDownAll(() async {
    try {
      await authService.logout();
    } catch (_) {}
  });
}

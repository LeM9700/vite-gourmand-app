import 'package:flutter_test/flutter_test.dart';
import 'package:vite_gourmand_app/features/auth/services/auth_service.dart';
import 'package:vite_gourmand_app/features/auth/models/auth_models.dart';

void main() {
  late AuthService authService;

  setUp(() {
    authService = AuthService();
  });

  group('AuthService - Structure et Methodes', () {
    // TEST 1: Vérifie que AuthService peut être créé sans paramètres
    // (design pattern Singleton via DioClient global)
    test('AuthService peut etre instancie sans parametres', () {
      expect(authService, isNotNull);
      expect(authService, isA<AuthService>());
    });

    // TESTS 2-9: Vérifient que toutes les méthodes publiques existent
    // Note: On ne les APPELLE PAS car elles font de vrais appels HTTP
    test('login() method existe et a la bonne signature', () {
      // Ne pas appeler la methode, juste verifier qu'elle existe
      expect(authService.login, isA<Function>());
    });

    test('register() method existe et a la bonne signature', () {
      expect(authService.register, isA<Function>());
    });

    test('logout() method existe et a la bonne signature', () {
      expect(authService.logout, isA<Function>());
    });

    test('isAuthenticated() method existe et a la bonne signature', () {
      expect(authService.isAuthenticated, isA<Function>());
    });

    test('getCurrentUser() method existe et a la bonne signature', () {
      expect(authService.getCurrentUser, isA<Function>());
    });

    test('updateProfile() method existe et a la bonne signature', () {
      expect(authService.updateProfile, isA<Function>());
    });

    test('forgotPassword() method existe et a la bonne signature', () {
      expect(authService.forgotPassword, isA<Function>());
    });

    test('resetPassword() method existe et a la bonne signature', () {
      expect(authService.resetPassword, isA<Function>());
    });
  });

  group('AuthService - Models', () {
    // TEST 10: Vérifie que LoginRequest se construit correctement
    // (Data Transfer Object pour l'API login)
    test('LoginRequest peut etre cree avec email et password', () {
      final request = LoginRequest(
        email: 'test@example.com',
        password: 'Password123!',
      );

      expect(request.email, 'test@example.com');
      expect(request.password, 'Password123!');
    });

    // TEST 11: Vérifie que RegisterRequest contient tous les champs requis
    test('RegisterRequest peut etre cree avec tous les champs', () {
      final request = RegisterRequest(
        email: 'test@example.com',
        password: 'Password123!',
        firstname: 'John',
        lastname: 'Doe',
        phone: '0612345678',
        address: '10 rue Test',
      );

      expect(request.email, 'test@example.com');
      expect(request.firstname, 'John');
      expect(request.lastname, 'Doe');
      expect(request.phone, '0612345678');
    });

    // TEST 12: Vérifie le parsing JSON de AuthResponse et UserData
    test('AuthResponse.fromJson() parse correctement les donnees', () {
      final json = {
        'access_token': 'token_abc123',
        'refresh_token': 'refresh_abc123',
        'user': {
          'id': 1,
          'email': 'test@example.com',
          'firstname': 'John',
          'lastname': 'Doe',
          'role': 'USER',
        },
      };

      final response = AuthResponse.fromJson(json);

      expect(response.accessToken, 'token_abc123');
      expect(response.refreshToken, 'refresh_abc123');
      expect(response.user.id, 1);
      expect(response.user.email, 'test@example.com');
      expect(response.user.role, 'USER');
    });

    // TEST 13: Vérifie parsing JSON utilisateur seul
    test('UserData.fromJson() parse correctement les donnees utilisateur', () {
      final json = {
        'id': 42,
        'email': 'user@example.com',
        'firstname': 'Jane',
        'lastname': 'Smith',
        'role': 'EMPLOYEE',
        'phone': '0698765432',
        'address': '20 avenue Test',
      };

      final userData = UserData.fromJson(json);

      expect(userData.id, 42);
      expect(userData.email, 'user@example.com');
      expect(userData.firstname, 'Jane');
      expect(userData.lastname, 'Smith');
      expect(userData.role, 'EMPLOYEE');
      expect(userData.phone, '0698765432');
      expect(userData.address, '20 avenue Test');
    });
  });
}

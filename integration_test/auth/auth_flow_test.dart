import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vite_gourmand_app/features/auth/services/auth_service.dart';
import 'package:vite_gourmand_app/features/auth/models/auth_models.dart';
import 'package:vite_gourmand_app/core/storage/secure_storage.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AuthService authService;
  late SecureStorage storage;
  final testEmail =
      'integration_test_${DateTime.now().millisecondsSinceEpoch}@test.com';
  final testPassword = 'TestPass123!';

  setUpAll(() {
    authService = AuthService();
    storage = SecureStorage();
  });

  group('Auth Flow - Integration Tests', () {
    // TEST 1: Inscription d'un nouvel utilisateur
    test('01 - Register crée un nouveau compte utilisateur', () async {
      // Arrange
      final registerRequest = RegisterRequest(
        email: testEmail,
        password: testPassword,
        firstname: 'Test',
        lastname: 'User',
        phone: '0612345678',
        address: '10 rue Test, 33000 Bordeaux',
      );

      // Act
      final response = await authService.register(registerRequest);

      // Assert
      expect(response, isA<AuthResponse>());
      expect(response.accessToken, isNotEmpty);
      expect(response.refreshToken, isNotEmpty);
      expect(response.user.email, testEmail);
      expect(response.user.firstname, 'Test');
      expect(response.user.role, 'USER');

      // Vérifier que le token est sauvegardé
      final savedToken = await storage.readToken();
      expect(savedToken, isNotNull);
      expect(savedToken, response.accessToken);

      final savedRole = await storage.readRole();
      expect(savedRole, 'USER');
    });

    // TEST 2: Connexion avec identifiants valides
    test('02 - Login avec identifiants valides retourne token', () async {
      // Arrange
      final loginRequest = LoginRequest(
        email: testEmail,
        password: testPassword,
      );

      // Act
      final response = await authService.login(loginRequest);

      // Assert
      expect(response, isA<AuthResponse>());
      expect(response.accessToken, isNotEmpty);
      expect(response.user.email, testEmail);
      expect(response.user.isUser, true);
    });

    // TEST 3: Connexion avec mot de passe invalide
    test('03 - Login avec mot de passe invalide échoue', () async {
      // Arrange
      final loginRequest = LoginRequest(
        email: testEmail,
        password: 'WrongPassword123!',
      );

      // Act & Assert
      expect(() => authService.login(loginRequest), throwsA(isA<Exception>()));
    });

    // TEST 4: Accès à un endpoint protégé avec token valide
    test(
      '04 - getCurrentUser() retourne données utilisateur connecté',
      () async {
        // Arrange - d'abord se connecter
        await authService.login(
          LoginRequest(email: testEmail, password: testPassword),
        );

        // Act
        final user = await authService.getCurrentUser();

        // Assert
        expect(user, isA<UserData>());
        expect(user.email, testEmail);
        expect(user.firstname, 'Test');
        expect(user.lastname, 'User');
        expect(user.role, 'USER');
      },
    );

    // TEST 5: Mise à jour du profil utilisateur
    test('05 - updateProfile() met à jour les données utilisateur', () async {
      // Arrange - connecté du test précédent

      // Act
      final updatedUser = await authService.updateProfile(
        firstname: 'TestUpdated',
        lastname: 'UserUpdated',
      );

      // Assert
      expect(updatedUser.firstname, 'TestUpdated');
      expect(updatedUser.lastname, 'UserUpdated');
      expect(updatedUser.email, testEmail); // Email inchangé
    });

    // TEST 6: Déconnexion et vérification token supprimé
    test('06 - logout() supprime le token et déconnecte', () async {
      // Act
      await authService.logout();

      // Assert
      final token = await storage.readToken();
      final role = await storage.readRole();

      expect(token, isNull);
      expect(role, isNull);

      // Vérifier qu'on ne peut plus accéder aux endpoints protégés
      expect(() => authService.getCurrentUser(), throwsA(isA<Exception>()));
    });

    // TEST 7: isAuthenticated() retourne false après logout
    test('07 - isAuthenticated() retourne false après logout', () async {
      // Arrange - déjà déconnecté du test précédent

      // Act
      final isAuth = await authService.isAuthenticated();

      // Assert
      expect(isAuth, false);
    });

    // TEST 8: isAuthenticated() retourne true après login
    test('08 - isAuthenticated() retourne true après login', () async {
      // Arrange - se reconnecter
      await authService.login(
        LoginRequest(email: testEmail, password: testPassword),
      );

      // Act
      final isAuth = await authService.isAuthenticated();

      // Assert
      expect(isAuth, true);
    });
  });

  tearDownAll(() async {
    // Nettoyage final
    try {
      await storage.clearAll();
    } catch (e) {
      // Ignorer erreurs nettoyage
    }
  });
}

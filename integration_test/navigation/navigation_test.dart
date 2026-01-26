import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vite_gourmand_app/main.dart' as app;
import 'package:vite_gourmand_app/features/auth/services/auth_service.dart';
import 'package:vite_gourmand_app/features/auth/models/auth_models.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AuthService authService;
  final testEmail =
      'nav_test_${DateTime.now().millisecondsSinceEpoch}@test.com';
  final testPassword = 'TestNav123!';

  setUpAll(() {
    authService = AuthService();
  });

  group('Navigation Flow - Integration Tests', () {
    testWidgets('01 - App démarre sur HomePage si non connecté', (
      tester,
    ) async {
      // Arrange
      await authService.logout(); // S'assurer qu'on est déconnecté

      // Act
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Assert - HomePage avec drawer/menu visible
      expect(find.byIcon(Icons.menu), findsOneWidget); // Burger menu
      expect(find.text('Vite & Gourmand'), findsWidgets); // Titre app
    });

    testWidgets('02 - Drawer navigation - Menus', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Act - Ouvrir drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Act - Cliquer sur "Menus"
      await tester.tap(find.text('Menus'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Assert - MenusListPage affichée
      expect(find.text('Nos Menus'), findsOneWidget);
    });

    testWidgets('03 - Drawer navigation - Connexion', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Act - Ouvrir drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Act - Cliquer sur "Connexion"
      await tester.tap(find.text('Connexion'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Assert - AuthPage affichée
      expect(find.text('Connexion'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2)); // Email + Password
    });

    testWidgets('04 - Navigation Login → Register', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Naviguer vers login
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Connexion'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Act - Cliquer sur "Créer un compte"
      await tester.tap(find.text('Créer un compte'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Inscription'), findsOneWidget);
      expect(
        find.byType(TextField),
        findsNWidgets(5),
      ); // Nom, prénom, email, tel, password
    });

    testWidgets('05 - Navigation après login réussie → MainNavigationPage', (
      tester,
    ) async {
      // Arrange - Créer un utilisateur
      final registerRequest = RegisterRequest(
        firstname: 'Nav',
        lastname: 'Test',
        email: testEmail,
        password: testPassword,
        phone: '+33612345678',
        address: '1 rue Inexistante, 33000 Bordeaux',
      );
      await authService.register(registerRequest);

      // Act - Login
      final loginRequest = LoginRequest(
        email: testEmail,
        password: testPassword,
      );
      await authService.login(loginRequest);

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Assert - MainNavigationPage avec bottom nav (USER)
      expect(find.text('Menus'), findsOneWidget);
      expect(find.text('Commandes'), findsOneWidget);
      expect(find.text('Suivi'), findsOneWidget);
      expect(find.text('Paramètres'), findsOneWidget);
    });

    testWidgets('06 - Bottom navigation USER - Switch tabs', (tester) async {
      // Pré-requis : être connecté (utiliser le user du test précédent)
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Test 1 : Tab Menus → Commandes
      await tester.tap(find.text('Commandes'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Mes Commandes'), findsOneWidget);

      // Test 2 : Tab Commandes → Suivi
      await tester.tap(find.text('Suivi'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Suivi de commande'), findsOneWidget);

      // Test 3 : Tab Suivi → Paramètres
      await tester.tap(find.text('Paramètres'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Profil'), findsWidgets);
    });

    testWidgets('07 - Déconnexion → Retour HomePage', (tester) async {
      // Arrange - être connecté
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Act - Aller dans Paramètres
      await tester.tap(find.text('Paramètres'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Act - Cliquer sur "Déconnexion"
      await tester.tap(find.text('Déconnexion'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Assert - Retour HomePage non connectée
      expect(find.byIcon(Icons.menu), findsOneWidget); // Drawer visible
    });

    testWidgets('08 - Navigation EMPLOYEE - Bottom nav 4 tabs', (tester) async {
      // Créer un user EMPLOYEE et tester navigation
      // Tabs : Commandes, SAV, Gestion, Profil
    });

    testWidgets('09 - Navigation ADMIN - Bottom nav 5 tabs', (tester) async {
      //Créer un user ADMIN et tester navigation
      // Tabs : Dashboard, Employés, Stats, Gestion, Réglages
    });

    testWidgets('10 - Deep link vitegourmand://orders/123', (tester) async {
      // Tester deep linking
      // Nécessite configuration uni_links en test
    });
  });

  tearDownAll(() async {
    // Cleanup
    try {
      await authService.logout();
    } catch (_) {}
  });
}

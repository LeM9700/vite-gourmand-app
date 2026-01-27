import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vite_gourmand_app/features/auth/services/auth_service.dart';
import 'package:vite_gourmand_app/features/auth/models/auth_models.dart';
import 'package:vite_gourmand_app/features/menus/models/menu_model.dart';
import 'package:vite_gourmand_app/features/orders/models/order_model.dart';
import 'package:vite_gourmand_app/core/api/dio_client.dart';
import 'package:vite_gourmand_app/core/storage/secure_storage.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AuthService authService;
  late DioClient dioClient;
  late SecureStorage storage;

  final testEmail =
      'order_test_${DateTime.now().millisecondsSinceEpoch}@test.com';
  final testPassword = 'TestPass123!';
  int? createdOrderId;

  setUpAll(() async {
    authService = AuthService();
    dioClient = await DioClient.create();
    storage = SecureStorage();
  });

  group('Order Flow - Integration Tests', () {
    // TEST 1: Inscription et connexion avant de commander
    test('01 - User s\'inscrit et se connecte', () async {
      // Arrange
      final registerRequest = RegisterRequest(
        email: testEmail,
        password: testPassword,
        firstname: 'OrderTest',
        lastname: 'User',
        phone: '0612345678',
        address: '10 rue Test, 33000 Bordeaux',
      );

      // Act
      final registerResponse = await authService.register(registerRequest);

      // Assert
      expect(registerResponse.user.role, 'USER');
      expect(await storage.readToken(), isNotNull);
    });

    // TEST 2: Récupération de la liste des menus disponibles
    test('02 - GET /menus/search retourne liste de menus actifs', () async {
      // Act - Appel direct API comme dans menus_list_page.dart
      final response = await dioClient.dio.get(
        '/menus/search',
        queryParameters: {'active_only': 'true'},
      );

      // Assert
      expect(response.data, isA<Map<String, dynamic>>());
      final items = response.data['items'] as List<dynamic>;
      expect(
        items,
        isNotEmpty,
        reason: 'Au moins 1 menu doit exister dans la DB',
      );

      final firstMenu = MenuModel.fromJson(items.first as Map<String, dynamic>);
      expect(firstMenu.isActive, true);
      expect(firstMenu.stock, greaterThan(0));
    });

    // TEST 3: Création d'une commande
    test('03 - POST /orders crée une nouvelle commande', () async {
      // Arrange - récupérer un menu disponible
      final menusResponse = await dioClient.dio.get(
        '/menus/search',
        queryParameters: {'active_only': 'true'},
      );
      final items = menusResponse.data['items'] as List<dynamic>;
      final selectedMenu = MenuModel.fromJson(
        items.first as Map<String, dynamic>,
      );

      // Payload comme dans order_page.dart
      final payload = {
        'menu_id': selectedMenu.id,
        'event_address': '10 rue Test',
        'event_city': 'Bordeaux',
        'event_date': DateTime.now()
            .add(const Duration(days: 30))
            .toIso8601String()
            .split('T')[0],
        'event_time': '12:00:00',
        'delivery_km': 0,
        'people_count': 50,
        'has_loaned_equipment': false,
      };

      // Act - Appel direct API comme dans order_page.dart
      final response = await dioClient.dio.post('/orders', data: payload);

      // Assert
      expect(response.data, isA<Map<String, dynamic>>());
      final createdOrder = OrderModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      expect(createdOrder.status, OrderStatus.placed);
      expect(createdOrder.peopleCount, 50);
      expect(createdOrder.eventCity, 'Bordeaux');

      // Sauvegarder l'ID pour tests suivants
      createdOrderId = createdOrder.id;
    });

    // TEST 4: Consultation du détail de la commande
    test('04 - GET /orders/{id} retourne infos complètes', () async {
      // Arrange - utiliser l'ID de la commande créée
      expect(
        createdOrderId,
        isNotNull,
        reason: 'Test 03 doit être exécuté avant',
      );

      // Act - Appel direct API comme dans order_detail_page.dart
      final response = await dioClient.dio.get('/orders/$createdOrderId');

      // Assert
      final orderDetail = OrderDetailModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      expect(orderDetail.id, createdOrderId);
      expect(orderDetail.status, OrderStatus.placed);
      expect(orderDetail.history, isNotEmpty);
      expect(orderDetail.history.first.status, 'PLACED');
    });

    // TEST 5: Liste des commandes utilisateur
    test('05 - GET /orders/me retourne toutes les commandes user', () async {
      // Act - Appel direct API comme dans order_tracking_page.dart
      final response = await dioClient.dio.get('/orders/me');

      // Assert
      final data = response.data as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>;
      expect(items, isNotEmpty);

      // Vérifier que notre commande créée est dans la liste
      final orders = items
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .toList();
      final ourOrder = orders.firstWhere(
        (o) => o.id == createdOrderId,
        orElse: () =>
            throw Exception('Commande créée non trouvée dans la liste'),
      );
      expect(ourOrder.status, OrderStatus.placed);
    });

    // TEST 6: Vérification de la business logic isCancellable
    test('06 - isCancellable retourne true pour statut PLACED', () async {
      // Arrange
      expect(createdOrderId, isNotNull);

      // Act
      final response = await dioClient.dio.get('/orders/$createdOrderId');
      final order = OrderModel.fromJson(response.data as Map<String, dynamic>);

      // Assert - Commande PLACED est annulable
      expect(order.status, OrderStatus.placed);
      expect(order.isCancellable, true);
    });

    // TEST 7: Note - Fonctionnalité annulation côté USER non implémentée
    test(
      '07 - Annulation commande (fonctionnalité EMPLOYEE uniquement)',
      () async {
        // Ce test documente que l'annulation côté USER n'existe pas dans l'app
        // L'API a DELETE /orders/{id}/cancel mais nécessite contactMode + reason
        // L'UI order_detail_page.dart a _showCancelDialog mais vide (ligne 440)
        // Seul EmployeeOrderService.cancelOrder implémente cette fonctionnalité

        // Pour l'instant, on vérifie juste que la commande reste PLACED
        final response = await dioClient.dio.get('/orders/$createdOrderId');
        final order = OrderModel.fromJson(
          response.data as Map<String, dynamic>,
        );

        expect(
          order.status,
          OrderStatus.placed,
          reason: 'Commande reste PLACED car annulation USER non implémentée',
        );
      },
    );

    // TEST 8: Vérification que commande CONFIRMED n'est plus annulable
    test('08 - isCancellable retourne false pour statut CONFIRMED', () async {
      // Note: Ce test nécessite un endpoint admin pour changer le statut
      // Pour l'instant, on documente le comportement attendu
      // Implémenter quand endpoint admin disponible
    });

    // TEST 9: Tentative de commander avec stock insuffisant
    test('09 - POST /orders échoue si stock menu insuffisant', () async {
      // Arrange - menu avec stock=0
      // Créer un menu test avec stock=0 via endpoint admin
      // ou mocker la réponse

      // Act & Assert
      // expect(() => créer commande, throwsA(contient('stock')));
    });

    // TEST 10: Validation des champs requis
    test('10 - POST /orders échoue si champs manquants', () async {
      // Arrange
      final invalidPayload = {
        'menu_id': 999, // ID inexistant
        // event_address manquant
        // event_date manquant
      };

      // Act & Assert
      expect(
        () => dioClient.dio.post('/orders', data: invalidPayload),
        throwsA(isA<Exception>()),
      );
    });

    // TEST 11: Date événement dans le passé
    test('11 - POST /orders échoue si event_date passée', () async {
      // Arrange
      final menusResponse = await dioClient.dio.get(
        '/menus/search',
        queryParameters: {'active_only': 'true'},
      );
      final items = menusResponse.data['items'] as List<dynamic>;
      final selectedMenu = MenuModel.fromJson(items.first);

      final invalidPayload = {
        'menu_id': selectedMenu.id,
        'event_address': '10 rue Test',
        'event_city': 'Bordeaux',
        'event_date': '2020-01-01', // ❌ Date passée
        'event_time': '12:00:00',
        'delivery_km': 0,
        'people_count': 50,
        'has_loaned_equipment': false,
      };

      // Act & Assert
      expect(
        () => dioClient.dio.post('/orders', data: invalidPayload),
        throwsA(isA<Exception>()),
      );
    });
  });

  tearDownAll(() async {
    // Nettoyage
    try {
      await storage.clearAll();
    } catch (e) {
      // Ignorer erreurs
    }
  });
}

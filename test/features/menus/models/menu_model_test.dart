import 'package:flutter_test/flutter_test.dart';
import 'package:vite_gourmand_app/features/menus/models/menu_model.dart';

void main() {
  group('MenuModel - Parsing JSON', () {
    // TEST 1: Vérifie que toutes les données d'un menu sont parsées correctement
    // (test du happy path complet)
    test('fromJson() parse correctement les données complètes', () {
      // Arrange
      final json = {
        'id': 1,
        'title': 'Menu Mariage',
        'description': 'Menu raffiné pour mariages',
        'theme': 'Mariage',
        'regime': 'Classique',
        'min_people': 50,
        'base_price': 45.99,
        'conditions_text': 'Réservation 2 semaines avant',
        'stock': 100,
        'is_active': true,
        'created_at': '2024-01-15T10:30:00Z',
        'updated_at': '2024-01-20T14:45:00Z',
        'images': [
          {
            'id': 1,
            'menu_id': 1,
            'url': 'https://example.com/image1.jpg',
            'alt_text': 'Photo menu',
            'sort_order': 0,
          },
        ],
        'dishes': [
          {
            'id': 1,
            'name': 'Saumon fumé',
            'dish_type': 'STARTER',
            'description': 'Saumon fumé maison',
            'allergens': [],
          },
        ],
      };

      // Act
      final menu = MenuModel.fromJson(json);

      // Assert
      expect(menu.id, 1);
      expect(menu.title, 'Menu Mariage');
      expect(menu.description, 'Menu raffiné pour mariages');
      expect(menu.theme, 'Mariage');
      expect(menu.regime, 'Classique');
      expect(menu.minPeople, 50);
      expect(menu.basePrice, 45.99);
      expect(menu.conditionsText, 'Réservation 2 semaines avant');
      expect(menu.stock, 100);
      expect(menu.isActive, true);
      expect(menu.createdAt, isNotNull);
      expect(menu.updatedAt, isNotNull);
      expect(menu.images.length, 1);
      expect(menu.dishes.length, 1);
    });

    // TEST 2: Vérifie la gestion des champs manquants
    // (robustesse : API peut retourner JSON incomplet)
    test('fromJson() gère les champs manquants avec valeurs par défaut', () {
      // Arrange
      final json = {'id': 2, 'images': [], 'dishes': []};

      // Act
      final menu = MenuModel.fromJson(json);

      // Assert
      expect(menu.id, 2);
      expect(menu.title, '');
      expect(menu.description, '');
      expect(menu.theme, '');
      expect(menu.regime, '');
      expect(menu.minPeople, 2);
      expect(menu.basePrice, 0.0);
      expect(menu.stock, 0);
      expect(menu.isActive, true);
      expect(menu.images, isEmpty);
      expect(menu.dishes, isEmpty);
    });

    // TEST 3: Vérifie la conversion String → double pour base_price
    // (L'API peut retourner "49.99" (String) au lieu de 49.99 (double))
    test('fromJson() convertit correctement base_price de String à double', () {
      // Arrange
      final json = {'id': 3, 'base_price': '49.99', 'images': [], 'dishes': []};

      // Act
      final menu = MenuModel.fromJson(json);

      // Assert
      expect(menu.basePrice, 49.99);
    });
  });

  group('MenuImage - Parsing JSON', () {
    // TEST 4: Vérifie parsing d'une image de menu
    test('fromJson() parse correctement une image', () {
      // Arrange
      final json = {
        'id': 1,
        'menu_id': 10,
        'url': 'https://example.com/photo.jpg',
        'alt_text': 'Photo du menu',
        'sort_order': 2,
      };

      // Act
      final image = MenuImage.fromJson(json);

      // Assert
      expect(image.id, 1);
      expect(image.menuId, 10);
      expect(image.imageUrl, 'https://example.com/photo.jpg');
      expect(image.altText, 'Photo du menu');
      expect(image.sortOrder, 2);
    });

    // TEST 5: Vérifie valeurs par défaut image
    test('fromJson() utilise valeurs par défaut si champs manquants', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final image = MenuImage.fromJson(json);

      // Assert
      expect(image.id, 0);
      expect(image.menuId, 0);
      expect(image.imageUrl, '');
      expect(image.altText, isNull);
      expect(image.sortOrder, 0);
    });
  });

  group('Dish - Parsing JSON', () {
    // TEST 6: Vérifie parsing d'un plat avec allergènes
    test('fromJson() parse correctement un plat', () {
      // Arrange
      final json = {
        'id': 5,
        'name': 'Filet mignon',
        'dish_type': 'MAIN',
        'description': 'Filet de bœuf tendre',
        'allergens': [
          {'id': 1, 'allergen': 'Gluten'},
        ],
      };

      // Act
      final dish = Dish.fromJson(json);

      // Assert
      expect(dish.id, 5);
      expect(dish.name, 'Filet mignon');
      expect(dish.dishType, 'MAIN');
      expect(dish.description, 'Filet de bœuf tendre');
      expect(dish.allergens.length, 1);
      expect(dish.allergens.first.allergen, 'Gluten');
    });

    // TEST 7: Vérifie traduction des types de plats en français
    test('dishTypeName retourne le nom traduit en français', () {
      // Assert
      expect(
        Dish(
          id: 1,
          name: 'Test',
          dishType: 'STARTER',
          description: '',
          allergens: [],
        ).dishTypeName,
        'Entrée',
      );
      expect(
        Dish(
          id: 2,
          name: 'Test',
          dishType: 'MAIN',
          description: '',
          allergens: [],
        ).dishTypeName,
        'Plat',
      );
      expect(
        Dish(
          id: 3,
          name: 'Test',
          dishType: 'DESSERT',
          description: '',
          allergens: [],
        ).dishTypeName,
        'Dessert',
      );
      expect(
        Dish(
          id: 4,
          name: 'Test',
          dishType: 'UNKNOWN',
          description: '',
          allergens: [],
        ).dishTypeName,
        'UNKNOWN',
      );
    });

    // TEST 8: Vérifie getters alternatifs (compatibility layer)
    test('category et title sont des getters compatibles', () {
      // Arrange
      final dish = Dish(
        id: 1,
        name: 'Tarte tatin',
        dishType: 'DESSERT',
        description: 'Tarte aux pommes caramélisées',
        allergens: [],
      );

      // Assert
      expect(dish.category, 'DESSERT');
      expect(dish.title, 'Tarte tatin');
      expect(dish.isActive, true);
    });
  });

  group('DishAllergen - Parsing JSON', () {
    // TEST 9: Vérifie parsing d'un allergène
    test('fromJson() parse correctement un allergène', () {
      // Arrange
      final json = {'id': 3, 'allergen': 'Lactose'};

      // Act
      final allergen = DishAllergen.fromJson(json);

      // Assert
      expect(allergen.id, 3);
      expect(allergen.allergen, 'Lactose');
    });

    // TEST 10: Vérifie valeurs par défaut allergène
    test('fromJson() gère les valeurs par défaut', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final allergen = DishAllergen.fromJson(json);

      // Assert
      expect(allergen.id, 0);
      expect(allergen.allergen, '');
    });
  });

  group('MenuModel - Getter imageUrl', () {
    // TEST 11: Vérifie getter imageUrl retourne la première image si disponible
    test('imageUrl retourne la première image si disponible', () {
      // Arrange
      final menu = MenuModel(
        id: 1,
        title: 'Test',
        description: 'Test',
        theme: 'Test',
        regime: 'Test',
        minPeople: 2,
        basePrice: 0.0,
        conditionsText: 'Test',
        stock: 0,
        isActive: true,
        images: [
          MenuImage(
            id: 1,
            menuId: 1,
            imageUrl: 'https://first.jpg',
            sortOrder: 0,
          ),
          MenuImage(
            id: 2,
            menuId: 1,
            imageUrl: 'https://second.jpg',
            sortOrder: 1,
          ),
        ],
        dishes: [],
      );

      // Assert
      expect(menu.imageUrl, 'https://first.jpg');
    });

    // TEST 12: Vérifie getter imageUrl retourne null si aucune image
    test('imageUrl retourne null si aucune image', () {
      // Arrange
      final menu = MenuModel(
        id: 1,
        title: 'Test',
        description: 'Test',
        theme: 'Test',
        regime: 'Test',
        minPeople: 2,
        basePrice: 0.0,
        conditionsText: 'Test',
        stock: 0,
        isActive: true,
        images: [],
        dishes: [],
      );

      // Assert
      expect(menu.imageUrl, isNull);
    });
  });

  group('MenuModel - Validation', () {
    // TEST 16: Vérifie que minPeople négatif est accepté (validation côté backend)
    test('fromJson() accepte minPeople négatif sans validation', () {
      final json = {'id': 1, 'min_people': -5, 'images': [], 'dishes': []};

      final menu = MenuModel.fromJson(json);

      // Le model ne valide pas (validation côté API/backend)
      expect(menu.minPeople, -5);
    });

    // TEST 17: Vérifie que stock négatif est accepté (validation côté backend)
    test('fromJson() accepte stock négatif sans validation', () {
      final json = {'id': 1, 'stock': -10, 'images': [], 'dishes': []};

      final menu = MenuModel.fromJson(json);

      expect(menu.stock, -10);
    });

    // TEST 18: Vérifie parsing dates invalides
    test('fromJson() gère dates invalides sans crash', () {
      final json = {
        'id': 1,
        'created_at': 'invalid_date_format',
        'updated_at': 'also_invalid',
        'images': [],
        'dishes': [],
      };

      expect(() => MenuModel.fromJson(json), returnsNormally);
    });

    // TEST 19: Vérifie que basePrice négatif est accepté (validation côté backend)
    test('fromJson() accepte basePrice négatif sans validation', () {
      final json = {'id': 1, 'base_price': -99.99, 'images': [], 'dishes': []};

      final menu = MenuModel.fromJson(json);

      expect(menu.basePrice, -99.99);
    });
  });
}

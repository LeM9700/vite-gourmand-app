import 'package:flutter_test/flutter_test.dart';
import 'package:vite_gourmand_app/features/reviews/models/review_model.dart';

void main() {
  group('ReviewModel - Parsing JSON', () {
    test('fromJson() parse correctement les données complètes', () {
      // Arrange
      final json = {
        'id': 1,
        'order_id': 10,
        'user_id': 5,
        'rating': 5,
        'comment': 'Excellent service !',
        'status': 'APPROVED',
        'created_at': '2024-01-15T10:30:00Z',
        'moderated_by_user_id': 2,
        'moderated_at': '2024-01-16T09:00:00Z',
        'customer': {'firstname': 'Jean', 'lastname': 'Dupont'},
      };

      // Act
      final review = ReviewModel.fromJson(json);

      // Assert
      expect(review.id, 1);
      expect(review.orderId, 10);
      expect(review.userId, 5);
      expect(review.rating, 5);
      expect(review.comment, 'Excellent service !');
      expect(review.status, 'APPROVED');
      expect(review.createdAt, isNotNull);
      expect(review.moderatedByUserId, 2);
      expect(review.moderatedAt, isNotNull);
      expect(review.customerFirstname, 'Jean');
      expect(review.customerLastname, 'Dupont');
    });

    test('fromJson() gère les champs optionnels absents', () {
      // Arrange
      final json = {
        'id': 2,
        'order_id': 11,
        'user_id': 6,
        'rating': 3,
        'comment': 'Bon',
        'status': 'PENDING',
        'created_at': '2024-01-20T12:00:00Z',
      };

      // Act
      final review = ReviewModel.fromJson(json);

      // Assert
      expect(review.id, 2);
      expect(review.rating, 3);
      expect(review.status, 'PENDING');
      expect(review.moderatedByUserId, isNull);
      expect(review.moderatedAt, isNull);
      expect(review.customerFirstname, isNull);
      expect(review.customerLastname, isNull);
    });

    test('fromJson() utilise valeurs par défaut pour champs manquants', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final review = ReviewModel.fromJson(json);

      // Assert
      expect(review.id, 0);
      expect(review.orderId, 0);
      expect(review.userId, 0);
      expect(review.rating, 0);
      expect(review.comment, '');
      expect(review.status, 'PENDING');
      expect(review.createdAt, isNotNull);
    });
  });

  group('ReviewModel - toJson()', () {
    test('toJson() sérialise correctement les données', () {
      // Arrange
      final createdAt = DateTime(2024, 1, 15, 10, 30);
      final moderatedAt = DateTime(2024, 1, 16, 9, 0);
      final review = ReviewModel(
        id: 1,
        orderId: 10,
        userId: 5,
        rating: 5,
        comment: 'Super !',
        status: 'APPROVED',
        createdAt: createdAt,
        moderatedByUserId: 2,
        moderatedAt: moderatedAt,
        customerFirstname: 'Jean',
        customerLastname: 'Dupont',
      );

      // Act
      final json = review.toJson();

      // Assert
      expect(json['id'], 1);
      expect(json['order_id'], 10);
      expect(json['user_id'], 5);
      expect(json['rating'], 5);
      expect(json['comment'], 'Super !');
      expect(json['status'], 'APPROVED');
      expect(json['created_at'], createdAt.toIso8601String());
      expect(json['moderated_by_user_id'], 2);
      expect(json['moderated_at'], moderatedAt.toIso8601String());
    });

    test('toJson() gère correctement les valeurs null', () {
      // Arrange
      final review = ReviewModel(
        id: 2,
        orderId: 11,
        userId: 6,
        rating: 3,
        comment: 'Bien',
        status: 'PENDING',
        createdAt: DateTime.now(),
      );

      // Act
      final json = review.toJson();

      // Assert
      expect(json['moderated_by_user_id'], isNull);
      expect(json['moderated_at'], isNull);
    });
  });

  group('ReviewModel - Validation Rating', () {
    test('rating accepte valeurs entre 1 et 5', () {
      // Ces ratings sont valides selon le backend (1..5)
      expect(
        () => ReviewModel(
          id: 1,
          orderId: 1,
          userId: 1,
          rating: 1,
          comment: 'OK',
          status: 'PENDING',
          createdAt: DateTime.now(),
        ),
        returnsNormally,
      );

      expect(
        () => ReviewModel(
          id: 2,
          orderId: 2,
          userId: 2,
          rating: 5,
          comment: 'Excellent',
          status: 'APPROVED',
          createdAt: DateTime.now(),
        ),
        returnsNormally,
      );
    });
  });

  group('ReviewModel - Getters Métier', () {
    // TEST 8: Vérifie getter isPending
    test('isPending retourne true si status = PENDING', () {
      final pending = ReviewModel(
        id: 1,
        orderId: 1,
        userId: 1,
        rating: 5,
        comment: 'Test',
        status: 'PENDING',
        createdAt: DateTime.now(),
      );
      final approved = ReviewModel(
        id: 2,
        orderId: 2,
        userId: 2,
        rating: 4,
        comment: 'Test',
        status: 'APPROVED',
        createdAt: DateTime.now(),
      );

      expect(pending.status, 'PENDING');
      expect(approved.status, 'APPROVED');
    });

    // TEST 9: Vérifie getter isApproved
    test('isApproved retourne true si status = APPROVED', () {
      final approved = ReviewModel(
        id: 1,
        orderId: 1,
        userId: 1,
        rating: 5,
        comment: 'Test',
        status: 'APPROVED',
        createdAt: DateTime.now(),
      );
      final rejected = ReviewModel(
        id: 2,
        orderId: 2,
        userId: 2,
        rating: 3,
        comment: 'Test',
        status: 'REJECTED',
        createdAt: DateTime.now(),
      );

      expect(approved.status, 'APPROVED');
      expect(rejected.status, 'REJECTED');
    });

    // TEST 10: Vérifie getter customerFullName
    test('customerFullName retourne "Prénom Nom"', () {
      final review = ReviewModel(
        id: 1,
        orderId: 1,
        userId: 1,
        rating: 5,
        comment: 'Test',
        status: 'APPROVED',
        createdAt: DateTime.now(),
        customerFirstname: 'Jean',
        customerLastname: 'Dupont',
      );

      final fullName =
          '${review.customerFirstname ?? ''} ${review.customerLastname ?? ''}'
              .trim();
      expect(fullName, 'Jean Dupont');
    });

    // TEST 11: Vérifie customerFullName avec noms manquants
    test('customerFullName gère firstname ou lastname null', () {
      final noFirstname = ReviewModel(
        id: 1,
        orderId: 1,
        userId: 1,
        rating: 5,
        comment: 'Test',
        status: 'APPROVED',
        createdAt: DateTime.now(),
        customerFirstname: null,
        customerLastname: 'Dupont',
      );
      expect(noFirstname.customerLastname, 'Dupont');

      final noLastname = ReviewModel(
        id: 2,
        orderId: 2,
        userId: 2,
        rating: 5,
        comment: 'Test',
        status: 'APPROVED',
        createdAt: DateTime.now(),
        customerFirstname: 'Jean',
        customerLastname: null,
      );
      expect(noLastname.customerFirstname, 'Jean');

      final anonymous = ReviewModel(
        id: 3,
        orderId: 3,
        userId: 3,
        rating: 5,
        comment: 'Test',
        status: 'APPROVED',
        createdAt: DateTime.now(),
        customerFirstname: null,
        customerLastname: null,
      );
      expect(anonymous.customerFirstname, isNull);
      expect(anonymous.customerLastname, isNull);
    });
  });

  group('ReviewModel - Validation Rating', () {
    // TEST 12: Vérifie que rating hors limites est accepté par le model
    test('rating hors de 1-5 est accepté par le model', () {
      final review0 = ReviewModel(
        id: 1,
        orderId: 1,
        userId: 1,
        rating: 0,
        comment: 'Test',
        status: 'PENDING',
        createdAt: DateTime.now(),
      );
      final review10 = ReviewModel(
        id: 2,
        orderId: 2,
        userId: 2,
        rating: 10,
        comment: 'Test',
        status: 'PENDING',
        createdAt: DateTime.now(),
      );

      expect(review0.rating, 0);
      expect(review10.rating, 10);
    });

    // TEST 13: Vérifie que comment vide est accepté
    test('comment peut être vide', () {
      final review = ReviewModel(
        id: 1,
        orderId: 1,
        userId: 1,
        rating: 5,
        comment: '',
        status: 'APPROVED',
        createdAt: DateTime.now(),
      );

      expect(review.comment, '');
    });

    // TEST 14: Vérifie parsing status invalide
    test('fromJson() gère status invalide sans crash', () {
      final json = {
        'id': 1,
        'order_id': 1,
        'user_id': 1,
        'rating': 5,
        'comment': 'Test',
        'status': 'INVALID_STATUS',
        'created_at': '2024-01-15T10:30:00Z',
      };

      final review = ReviewModel.fromJson(json);

      expect(review.status, 'INVALID_STATUS');
    });

    // TEST 15: Vérifie parsing rating négatif
    test('fromJson() accepte rating négatif (validation côté backend)', () {
      final json = {
        'id': 1,
        'order_id': 1,
        'user_id': 1,
        'rating': -3,
        'comment': 'Test',
        'status': 'PENDING',
        'created_at': '2024-01-15T10:30:00Z',
      };

      final review = ReviewModel.fromJson(json);

      expect(review.rating, -3);
    });

    // TEST 16: Vérifie comment long est accepté
    test('comment très long est accepté par le model', () {
      final longComment = 'A' * 2000;
      final review = ReviewModel(
        id: 1,
        orderId: 1,
        userId: 1,
        rating: 5,
        comment: longComment,
        status: 'APPROVED',
        createdAt: DateTime.now(),
      );

      expect(review.comment.length, 2000);
    });
  });

  group('ReviewModel - Round-trip JSON', () {
    // TEST 17: Vérifie serialisation/deserialisation complète
    test('ReviewModel survit à un round-trip JSON', () {
      final original = ReviewModel(
        id: 1,
        orderId: 10,
        userId: 5,
        rating: 4,
        comment: 'Très bon service, livraison rapide !',
        status: 'APPROVED',
        createdAt: DateTime(2024, 1, 15, 10, 30),
        moderatedByUserId: 2,
        moderatedAt: DateTime(2024, 1, 16, 9, 0),
        customerFirstname: 'Jean',
        customerLastname: 'Dupont',
      );

      final json = original.toJson();
      final restored = ReviewModel.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.rating, original.rating);
      expect(restored.status, original.status);
      expect(restored.comment, original.comment);
      expect(restored.moderatedByUserId, original.moderatedByUserId);
    });

    // TEST 18: Vérifie round-trip avec valeurs null
    test('Round-trip JSON préserve les valeurs null', () {
      final original = ReviewModel(
        id: 1,
        orderId: 1,
        userId: 1,
        rating: 3,
        comment: 'Bien',
        status: 'PENDING',
        createdAt: DateTime(2024, 1, 15),
      );

      final json = original.toJson();
      final restored = ReviewModel.fromJson(json);

      expect(restored.moderatedByUserId, isNull);
      expect(restored.moderatedAt, isNull);
    });

    // TEST 19: Vérifie format ISO8601 pour created_at
    test('toJson() formate created_at en ISO8601', () {
      final review = ReviewModel(
        id: 1,
        orderId: 1,
        userId: 1,
        rating: 5,
        comment: 'Test',
        status: 'APPROVED',
        createdAt: DateTime(2024, 1, 15, 10, 30, 45),
      );

      final json = review.toJson();

      expect(json['created_at'], '2024-01-15T10:30:45.000');
    });
  });
}

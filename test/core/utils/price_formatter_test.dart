import 'package:flutter_test/flutter_test.dart';
import 'package:vite_gourmand_app/core/utils/price_formatter.dart';

void main() {
  group('PriceFormatter Tests', () {
    test('formatPrice retourne format XX,XX €', () {
      // Assert - Contient les éléments attendus (espace insécable géré par NumberFormat)
      final result1 = PriceFormatter.formatPrice(45.99);
      expect(result1, contains('45,99'));
      expect(result1, contains('€'));

      final result2 = PriceFormatter.formatPrice(100.0);
      expect(result2, contains('100,00'));
      expect(result2, contains('€'));

      final result3 = PriceFormatter.formatPrice(9.5);
      expect(result3, contains('9,50'));
      expect(result3, contains('€'));
    });

    test('formatPrice gère prix négatifs', () {
      final result = PriceFormatter.formatPrice(-10.5);
      expect(result, contains('-10,50'));
      expect(result, contains('€'));
    });

    test('formatPrice gère zéro', () {
      final result = PriceFormatter.formatPrice(0);
      expect(result, contains('0,00'));
      expect(result, contains('€'));
    });

    test('formatPrice arrondit à 2 décimales', () {
      final result1 = PriceFormatter.formatPrice(45.999);
      expect(result1, contains('46,00'));

      final result2 = PriceFormatter.formatPrice(45.994);
      expect(result2, contains('45,99'));
    });

    test('formatPriceCompact retourne format sans décimales si entier', () {
      final result1 = PriceFormatter.formatPriceCompact(100.0);
      expect(result1, contains('100'));
      expect(result1, contains('€'));
      expect(result1, isNot(contains(',')));

      final result2 = PriceFormatter.formatPriceCompact(45.5);
      expect(result2, contains('45,50'));
      expect(result2, contains('€'));
    });
  });
}

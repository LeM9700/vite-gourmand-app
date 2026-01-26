import 'package:flutter_test/flutter_test.dart';
import 'package:vite_gourmand_app/core/utils/date_formatter.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr_FR', null);
  });

  group('DateFormatter Tests', () {
    test('formatDate retourne format DD/MM/YYYY', () {
      // Arrange
      final date = DateTime(2026, 3, 15);

      // Act
      final formatted = DateFormatter.formatDate(date);

      // Assert
      expect(formatted, '15/03/2026');
    });

    test('formatDateTime retourne format DD/MM/YYYY HH:mm', () {
      // Arrange
      final date = DateTime(2026, 3, 15, 14, 30);

      // Act
      final formatted = DateFormatter.formatDateTime(date);

      // Assert
      expect(formatted, '15/03/2026 14:30');
    });

    test('formatTime retourne format HH:mm', () {
      // Arrange
      final date = DateTime(2026, 3, 15, 9, 5);

      // Act
      final formatted = DateFormatter.formatTime(date);

      // Assert
      expect(formatted, '09:05');
    });

    test('formatDateLong retourne format français complet', () {
      // Arrange
      final date = DateTime(2026, 3, 15);

      // Act
      final formatted = DateFormatter.formatDateLong(date);

      // Assert
      expect(formatted, contains('15'));
      expect(formatted, contains('mars'));
      expect(formatted, contains('2026'));
    });

    test('daysBetween calcule différence correctement', () {
      // Arrange
      final date1 = DateTime(2026, 3, 15);
      final date2 = DateTime(2026, 3, 20);

      // Act
      final days = DateFormatter.daysBetween(date1, date2);

      // Assert
      expect(days, 5);
    });

    test('isToday retourne true pour date du jour', () {
      // Arrange
      final today = DateTime.now();

      // Act
      final result = DateFormatter.isToday(today);

      // Assert
      expect(result, true);
    });

    test('isToday retourne false pour date passée', () {
      // Arrange
      final yesterday = DateTime.now().subtract(const Duration(days: 1));

      // Act
      final result = DateFormatter.isToday(yesterday);

      // Assert
      expect(result, false);
    });
  });
}

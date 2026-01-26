import 'package:intl/intl.dart';

/// Utilitaires de formatage des prix
class PriceFormatter {
  /// Formateur français (virgule pour décimales)
  static final _currencyFormatter = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: '€',
    decimalDigits: 2,
  );

  /// Formate un prix avec 2 décimales et le symbole €
  /// Exemple: 45.99 → "45,99 €"
  static String formatPrice(double price) {
    return _currencyFormatter.format(price);
  }

  /// Formate un prix de manière compacte (sans décimales si entier)
  /// Exemple: 100.0 → "100 €", 45.5 → "45,50 €"
  static String formatPriceCompact(double price) {
    if (price == price.toInt()) {
      return NumberFormat.currency(
        locale: 'fr_FR',
        symbol: '€',
        decimalDigits: 0,
      ).format(price);
    }
    return formatPrice(price);
  }

  /// Formate un prix sans le symbole €
  /// Exemple: 45.99 → "45,99"
  static String formatPriceWithoutSymbol(double price) {
    return NumberFormat.currency(
      locale: 'fr_FR',
      symbol: '',
      decimalDigits: 2,
    ).format(price).trim();
  }

  /// Parse un prix depuis une string
  /// Exemple: "45,99 €" → 45.99
  static double? parsePrice(String priceStr) {
    try {
      // Nettoyer la string (enlever €, espaces)
      final cleaned = priceStr
          .replaceAll('€', '')
          .replaceAll(' ', '')
          .replaceAll(',', '.');

      return double.tryParse(cleaned);
    } catch (e) {
      return null;
    }
  }
}

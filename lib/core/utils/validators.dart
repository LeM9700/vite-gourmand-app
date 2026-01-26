/// Utilitaires de validation pour les formulaires
class Validators {
  // ==================== EMAIL ====================

  /// Valide le format d'un email
  static bool isValidEmail(String? email) {
    if (email == null || email.trim().isEmpty) return false;

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    return emailRegex.hasMatch(email.trim());
  }

  /// Retourne un message d'erreur si l'email est invalide
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'L\'email est requis';
    }
    if (!isValidEmail(email)) {
      return 'Format d\'email invalide';
    }
    return null;
  }

  // ==================== PASSWORD ====================

  /// Valide un mot de passe (min 8 caractères, 1 maj, 1 min, 1 chiffre, 1 spécial)
  static bool isValidPassword(String? password) {
    if (password == null || password.length < 8) return false;

    // Au moins une majuscule
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;

    // Au moins une minuscule
    if (!RegExp(r'[a-z]').hasMatch(password)) return false;

    // Au moins un chiffre
    if (!RegExp(r'[0-9]').hasMatch(password)) return false;

    // Au moins un caractère spécial
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) return false;

    return true;
  }

  /// Retourne un message d'erreur si le mot de passe est invalide
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Le mot de passe est requis';
    }
    if (password.length < 8) {
      return 'Minimum 8 caractères requis';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Au moins une majuscule requise';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Au moins une minuscule requise';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Au moins un chiffre requis';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Au moins un caractère spécial requis';
    }
    return null;
  }

  // ==================== PHONE ====================

  /// Valide un numéro de téléphone français
  static bool isValidPhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) return false;

    // Nettoyer les espaces et caractères spéciaux
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\.]'), '');

    // Format français : 0XXXXXXXXX ou +33XXXXXXXXX
    final phoneRegex = RegExp(r'^(0|\+33)[1-9][0-9]{8}$');

    return phoneRegex.hasMatch(cleaned);
  }

  /// Retourne un message d'erreur si le téléphone est invalide
  static String? validatePhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return 'Le numéro de téléphone est requis';
    }
    if (!isValidPhone(phone)) {
      return 'Format de téléphone invalide (ex: 06 12 34 56 78)';
    }
    return null;
  }

  // ==================== REQUIRED FIELDS ====================

  /// Vérifie qu'un champ n'est pas vide
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Retourne un message d'erreur si le champ est vide
  static String? validateRequired(
    String? value, {
    String fieldName = 'Ce champ',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est requis';
    }
    return null;
  }

  // ==================== NUMBERS ====================

  /// Vérifie qu'un nombre est positif
  static bool isPositiveNumber(num? value) {
    return value != null && value > 0;
  }

  /// Vérifie qu'un nombre est dans une plage
  static bool isInRange(num? value, {num? min, num? max}) {
    if (value == null) return false;
    if (min != null && value < min) return false;
    if (max != null && value > max) return false;
    return true;
  }

  /// Retourne un message d'erreur si le nombre est invalide
  static String? validateNumber(
    String? value, {
    String fieldName = 'Ce champ',
    num? min,
    num? max,
    bool required = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$fieldName est requis' : null;
    }

    final number = num.tryParse(value);
    if (number == null) {
      return '$fieldName doit être un nombre';
    }

    if (min != null && number < min) {
      return '$fieldName doit être supérieur ou égal à $min';
    }

    if (max != null && number > max) {
      return '$fieldName doit être inférieur ou égal à $max';
    }

    return null;
  }

  // ==================== LENGTH ====================

  /// Vérifie la longueur minimale
  static bool hasMinLength(String? value, int minLength) {
    return value != null && value.length >= minLength;
  }

  /// Vérifie la longueur maximale
  static bool hasMaxLength(String? value, int maxLength) {
    return value != null && value.length <= maxLength;
  }

  /// Retourne un message d'erreur si la longueur est invalide
  static String? validateLength(
    String? value, {
    String fieldName = 'Ce champ',
    int? min,
    int? max,
  }) {
    if (value == null || value.isEmpty) return null;

    if (min != null && value.length < min) {
      return '$fieldName doit contenir au moins $min caractères';
    }

    if (max != null && value.length > max) {
      return '$fieldName ne peut pas dépasser $max caractères';
    }

    return null;
  }

  // ==================== ADDRESS ====================

  /// Retourne un message d'erreur si l'adresse est invalide
  static String? validateAddress(String? address) {
    if (address == null || address.trim().isEmpty) {
      return 'L\'adresse est requise';
    }
    if (address.trim().length < 5) {
      return 'L\'adresse est trop courte';
    }
    return null;
  }

  // ==================== CITY ====================

  /// Retourne un message d'erreur si la ville est invalide
  static String? validateCity(String? city) {
    if (city == null || city.trim().isEmpty) {
      return 'La ville est requise';
    }
    if (city.trim().length < 2) {
      return 'La ville est trop courte';
    }
    return null;
  }

  // ==================== NAME ====================

  /// Retourne un message d'erreur si le nom est invalide
  static String? validateName(String? name, {String fieldName = 'Le nom'}) {
    if (name == null || name.trim().isEmpty) {
      return '$fieldName est requis';
    }
    if (name.trim().length < 2) {
      return '$fieldName est trop court';
    }
    if (!RegExp(r"^[a-zA-ZÀ-ÿ\s\-']+$").hasMatch(name)) {
      return '$fieldName contient des caractères invalides';
    }
    return null;
  }
}

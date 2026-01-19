/// Utilitaires pour la gestion des rôles utilisateurs
class UserRole {
  static const String user = 'USER';
  static const String employee = 'EMPLOYEE';
  static const String admin = 'ADMIN';

  /// Vérifie si le rôle est un employé ou admin
  static bool isStaff(String? role) {
    return role == employee || role == admin;
  }

  /// Vérifie si le rôle est admin
  static bool isAdmin(String? role) {
    return role == admin;
  }

  /// Vérifie si le rôle est un utilisateur standard
  static bool isUser(String? role) {
    return role == user;
  }

  /// Vérifie si le rôle est un employé (sans admin)
  static bool isEmployee(String? role) {
    return role == employee;
  }

  /// Retourne une description lisible du rôle
  static String getDisplayName(String? role) {
    switch (role) {
      case admin:
        return 'Administrateur';
      case employee:
        return 'Employé';
      case user:
        return 'Client';
      default:
        return 'Inconnu';
    }
  }
}

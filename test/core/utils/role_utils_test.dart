import 'package:flutter_test/flutter_test.dart';
import 'package:vite_gourmand_app/core/utils/role_utils.dart';

void main() {
  group('UserRole - isStaff', () {
    // TEST 1: Vérifie que EMPLOYEE est considéré comme staff
    // (staff = employés qui gèrent les commandes)
    test('isStaff retourne true pour EMPLOYEE', () {
      expect(UserRole.isStaff('EMPLOYEE'), true);
    });

    // TEST 2: Vérifie que ADMIN est considéré comme staff
    // (admins ont aussi accès gestion)
    test('isStaff retourne true pour ADMIN', () {
      expect(UserRole.isStaff('ADMIN'), true);
    });

    // TEST 3: Vérifie que USER (client) n'est PAS staff
    test('isStaff retourne false pour USER', () {
      expect(UserRole.isStaff('USER'), false);
    });

    // TEST 4: Gestion du cas null (utilisateur non connecté)
    test('isStaff retourne false pour null', () {
      expect(UserRole.isStaff(null), false);
    });

    // TEST 5: Gestion du cas string vide (données corrompues)
    test('isStaff retourne false pour string vide', () {
      expect(UserRole.isStaff(''), false);
    });

    // TEST 6: Gestion des rôles invalides (sécurité)
    test('isStaff retourne false pour rôle invalide', () {
      expect(UserRole.isStaff('INVALID_ROLE'), false);
    });
  });

  group('UserRole - isAdmin', () {
    // TEST 7: Seul ADMIN retourne true
    test('isAdmin retourne true pour ADMIN', () {
      expect(UserRole.isAdmin('ADMIN'), true);
    });

    // TEST 8: EMPLOYEE n'est PAS admin (privilèges moindres)
    test('isAdmin retourne false pour EMPLOYEE', () {
      expect(UserRole.isAdmin('EMPLOYEE'), false);
    });

    // TEST 9: USER n'est PAS admin
    test('isAdmin retourne false pour USER', () {
      expect(UserRole.isAdmin('USER'), false);
    });

    // TEST 10: Gestion null
    test('isAdmin retourne false pour null', () {
      expect(UserRole.isAdmin(null), false);
    });
  });

  group('UserRole - getDisplayName', () {
    // TEST 11: Retourne label français pour USER
    test('getDisplayName retourne "Client" pour USER', () {
      expect(UserRole.getDisplayName('USER'), 'Client');
    });

    // TEST 12: Retourne label français pour EMPLOYEE
    test('getDisplayName retourne "Employé" pour EMPLOYEE', () {
      expect(UserRole.getDisplayName('EMPLOYEE'), 'Employé');
    });

    // TEST 13: Retourne label français pour ADMIN
    test('getDisplayName retourne "Administrateur" pour ADMIN', () {
      expect(UserRole.getDisplayName('ADMIN'), 'Administrateur');
    });

    // TEST 14: Gestion des rôles invalides (fallback)
    test('getDisplayName retourne "Inconnu" pour rôle invalide', () {
      expect(UserRole.getDisplayName('INVALID'), 'Inconnu');
    });

    // TEST 15: Gestion null
    test('getDisplayName retourne "Inconnu" pour null', () {
      expect(UserRole.getDisplayName(null), 'Inconnu');
    });
  });
}

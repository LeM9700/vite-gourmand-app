import 'package:flutter_test/flutter_test.dart';
import 'package:vite_gourmand_app/core/utils/validators.dart';

void main() {
  group('Validators - Email', () {
    test('isValidEmail retourne true pour emails valides', () {
      expect(Validators.isValidEmail('test@example.com'), true);
      expect(Validators.isValidEmail('user+tag@domain.co.uk'), true);
      expect(Validators.isValidEmail('firstname.lastname@company.fr'), true);
    });

    test('isValidEmail retourne false pour emails invalides', () {
      expect(Validators.isValidEmail(''), false);
      expect(Validators.isValidEmail('notanemail'), false);
      expect(Validators.isValidEmail('@example.com'), false);
      expect(Validators.isValidEmail('user@'), false);
      expect(Validators.isValidEmail('user @example.com'), false);
    });
  });

  group('Validators - Password', () {
    test('isValidPassword retourne true pour mots de passe forts', () {
      expect(Validators.isValidPassword('Test123!'), true);
      expect(Validators.isValidPassword('MyP@ssw0rd'), true);
      expect(Validators.isValidPassword('C0mpl3x!Pass'), true);
    });

    test('isValidPassword retourne false si trop court', () {
      expect(Validators.isValidPassword('Test1!'), false); // < 8 caractères
    });

    test('isValidPassword retourne false sans majuscule', () {
      expect(Validators.isValidPassword('test123!'), false);
    });

    test('isValidPassword retourne false sans minuscule', () {
      expect(Validators.isValidPassword('TEST123!'), false);
    });

    test('isValidPassword retourne false sans chiffre', () {
      expect(Validators.isValidPassword('TestPass!'), false);
    });

    test('isValidPassword retourne false sans caractère spécial', () {
      expect(Validators.isValidPassword('TestPass1'), false);
    });
  });

  group('Validators - Phone', () {
    test('isValidPhone retourne true pour numéros français valides', () {
      expect(Validators.isValidPhone('0612345678'), true);
      expect(Validators.isValidPhone('+33612345678'), true);
      expect(Validators.isValidPhone('06 12 34 56 78'), true);
    });

    test('isValidPhone retourne false pour formats invalides', () {
      expect(Validators.isValidPhone(''), false);
      expect(Validators.isValidPhone('123'), false);
      expect(Validators.isValidPhone('abcdefghij'), false);
    });
  });

  group('Validators - Required Fields', () {
    test('isNotEmpty retourne true si non vide', () {
      expect(Validators.isNotEmpty('test'), true);
      expect(Validators.isNotEmpty('   test   '), true);
    });

    test('isNotEmpty retourne false si vide ou whitespace', () {
      expect(Validators.isNotEmpty(''), false);
      expect(Validators.isNotEmpty('   '), false);
      expect(Validators.isNotEmpty(null), false);
    });
  });

  group('Validators - Numbers', () {
    test('isPositiveNumber retourne true pour nombres > 0', () {
      expect(Validators.isPositiveNumber(1), true);
      expect(Validators.isPositiveNumber(999.99), true);
    });

    test('isPositiveNumber retourne false pour 0 ou négatifs', () {
      expect(Validators.isPositiveNumber(0), false);
      expect(Validators.isPositiveNumber(-5), false);
    });

    test('isInRange vérifie bornes correctement', () {
      expect(Validators.isInRange(5, min: 1, max: 10), true);
      expect(Validators.isInRange(1, min: 1, max: 10), true);
      expect(Validators.isInRange(10, min: 1, max: 10), true);

      expect(Validators.isInRange(0, min: 1, max: 10), false);
      expect(Validators.isInRange(11, min: 1, max: 10), false);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vite_gourmand_app/core/widgets/input_field.dart';

void main() {
  group('InputField Widget Tests', () {
    testWidgets('01 - Affiche le label', (tester) async {
      // Arrange
      final controller = TextEditingController();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputField(label: 'Email', controller: controller),
          ),
        ),
      );

      // Assert
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('02 - Saisie de texte fonctionne', (tester) async {
      // Arrange
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputField(label: 'Test', controller: controller),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), 'Hello Test');
      await tester.pumpAndSettle();

      // Assert
      expect(controller.text, 'Hello Test');
      expect(find.text('Hello Test'), findsOneWidget);
    });

    testWidgets('03 - Affiche errorText si présent', (tester) async {
      // Arrange
      final controller = TextEditingController();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputField(
              label: 'Field',
              controller: controller,
              errorText: 'Champ requis',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Champ requis'), findsOneWidget);
    });

    testWidgets('04 - obscureText masque le texte', (tester) async {
      // Arrange
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputField(
              label: 'Password',
              controller: controller,
              obscureText: true,
            ),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), 'secret123');
      await tester.pumpAndSettle();

      // Assert
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, true);
    });
  });
}

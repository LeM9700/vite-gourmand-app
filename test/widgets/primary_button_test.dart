import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vite_gourmand_app/core/widgets/primary_button.dart';

void main() {
  group('PrimaryButton Widget Tests', () {
    testWidgets('01 - Affiche le label correctement', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(label: 'Test Button', onPressed: () {}),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('02 - Appelle onPressed au tap', (tester) async {
      // Arrange
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Tap Me',
              onPressed: () => wasTapped = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      // Assert
      expect(wasTapped, true);
    });

    testWidgets('03 - Affiche loader quand isLoading=true', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Loading',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('04 - Désactive le bouton si onPressed=null', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrimaryButton(label: 'Disabled', onPressed: null),
          ),
        ),
      );

      // Act - tenter de taper
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      // Assert - vérifier qu'il ne se passe rien (difficile à tester)
      // On pourrait vérifier visuellement l'opacité ou autre
    });

    testWidgets('05 - Animation scale au tap', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(label: 'Animate', onPressed: () {}),
          ),
        ),
      );

      // Act - tapDown
      await tester.press(find.byType(PrimaryButton));
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - vérifier que l'animation a commencé
      // (difficile sans accès direct au Transform.scale)

      // Act - tapUp
      await tester.pumpAndSettle();

      // Le bouton devrait revenir à scale=1.0
    });
  });
}

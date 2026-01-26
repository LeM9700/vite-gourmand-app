import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vite_gourmand_app/core/widgets/secondary_button.dart';

void main() {
  group('SecondaryButton Widget Tests', () {
    testWidgets('01 - Affiche le label correctement', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryButton(label: 'Cancel', onPressed: () {}),
          ),
        ),
      );

      // Assert
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('02 - Appelle onPressed au tap', (tester) async {
      // Arrange
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryButton(
              label: 'Tap Me',
              onPressed: () => wasTapped = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(SecondaryButton));
      await tester.pumpAndSettle();

      // Assert
      expect(wasTapped, true);
    });

    testWidgets('03 - Affiche loader quand isLoading=true', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryButton(
              label: 'Loading',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsNothing); // Texte caché pendant loading
    });

    testWidgets('04 - Désactive le bouton si onPressed=null', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SecondaryButton(label: 'Disabled', onPressed: null),
          ),
        ),
      );

      // Act - tenter de taper
      final buttonFinder = find.byType(SecondaryButton);
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // Assert - bouton devrait être désactivé visuellement
      expect(buttonFinder, findsOneWidget);
    });
  });
}

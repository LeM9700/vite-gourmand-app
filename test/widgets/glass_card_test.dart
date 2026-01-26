import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vite_gourmand_app/core/widgets/glass_card.dart';

void main() {
  group('GlassCard Widget Tests', () {
    testWidgets('01 - Affiche le child correctement', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: GlassCard(child: Text('Card Content'))),
        ),
      );

      // Assert
      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('02 - Applique le padding correct', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(padding: EdgeInsets.all(32), child: Text('Padded')),
          ),
        ),
      );

      // Assert
      final paddingWidget = tester.widget<Container>(
        find
            .ancestor(of: find.text('Padded'), matching: find.byType(Container))
            .first,
      );
      expect(paddingWidget.padding, const EdgeInsets.all(32));
    });

    testWidgets('03 - onTap appelé au tap', (tester) async {
      // Arrange
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassCard(
              onTap: () => wasTapped = true,
              child: const Text('Tappable'),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(GlassCard));
      await tester.pumpAndSettle();

      // Assert
      expect(wasTapped, true);
    });
  });
}

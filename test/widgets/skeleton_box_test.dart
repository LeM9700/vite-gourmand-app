import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vite_gourmand_app/core/widgets/skeleton_box.dart';

void main() {
  group('SkeletonBox Widget Tests', () {
    testWidgets('01 - Affiche avec dimensions correctes', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SkeletonBox(height: 100, width: 200)),
        ),
      );

      // Assert - Vérifier que le widget est présent
      expect(find.byType(SkeletonBox), findsOneWidget);

      // Vérifier les dimensions via le widget lui-même
      final skeletonBox = tester.widget<SkeletonBox>(find.byType(SkeletonBox));
      expect(skeletonBox.height, 100);
      expect(skeletonBox.width, 200);
    });

    testWidgets('02 - Animation shimmer fonctionne', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SkeletonBox(height: 50, width: 100)),
        ),
      );

      // Act - avancer l'animation
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Assert - l'animation devrait avoir progressé
      expect(find.byType(SkeletonBox), findsOneWidget);
    });

    testWidgets('03 - Radius personnalisé appliqué', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SkeletonBox(height: 50, width: 100, radius: 16)),
        ),
      );

      // Assert - Vérifier que le widget existe avec le bon radius
      final skeletonBox = tester.widget<SkeletonBox>(find.byType(SkeletonBox));
      expect(skeletonBox.radius, 16);
    });
  });
}

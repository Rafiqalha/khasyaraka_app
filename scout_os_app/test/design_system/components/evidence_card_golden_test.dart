import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scout_os_app/design_system/components/evidence_card.dart';
import 'package:scout_os_app/design_system/theme/app_theme.dart';

void main() {
  group('EvidenceCard Golden Tests', () {
    Widget buildSubject(ThemeData theme) {
      return MaterialApp(
        theme: theme,
        home: const Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: EvidenceCard(
                observations: ['Loop Boundary Check', 'Variable Initialization'],
                impacts: {'Confidence': '+5%', 'Speed': '+10%'},
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('EvidenceCard Light Theme', (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject(PradigiTheme.lightTheme));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(EvidenceCard),
        matchesGoldenFile('goldens/evidence_card_light.png'),
      );
    });

    testWidgets('EvidenceCard Dark Theme', (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject(PradigiTheme.darkTheme));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(EvidenceCard),
        matchesGoldenFile('goldens/evidence_card_dark.png'),
      );
    });
  });
}

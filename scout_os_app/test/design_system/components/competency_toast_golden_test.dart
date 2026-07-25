import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scout_os_app/design_system/components/competency_toast.dart';
import 'package:scout_os_app/design_system/theme/app_theme.dart';

void main() {
  group('CompetencyToast Golden Tests', () {
    Widget buildSubject(ThemeData theme) {
      return MaterialApp(
        theme: theme,
        home: const Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CompetencyToast(
                title: 'Data Structures',
                delta: '+15%',
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('CompetencyToast Light Theme', (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject(PradigiTheme.lightTheme));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(CompetencyToast),
        matchesGoldenFile('goldens/competency_toast_light.png'),
      );
    });

    testWidgets('CompetencyToast Dark Theme', (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject(PradigiTheme.darkTheme));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(CompetencyToast),
        matchesGoldenFile('goldens/competency_toast_dark.png'),
      );
    });
  });
}

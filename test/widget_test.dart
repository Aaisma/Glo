import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glo/view/glo_derma_visit/follow_up_reminder.dart';

void main() {
  group('FollowUpReminderScreen widget tests', () {
    testWidgets(
      'renders without errors',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: FollowUpReminderScreen(),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(FollowUpReminderScreen), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
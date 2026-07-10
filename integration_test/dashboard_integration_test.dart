import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:glo/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Dashboard navigation smoke test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Verify we start on the DashboardHome page
    expect(find.text('Daily Journal'), findsOneWidget);
    expect(find.text('Water Tracker'), findsOneWidget);

    // Tap on Water Tracker card
    await tester.tap(find.text('Water Tracker'));
    await tester.pumpAndSettle();
    
    // We should be on WaterTrackerScreen. Navigate back.
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Tap on Medications card
    await tester.tap(find.text('Medications'));
    await tester.pumpAndSettle();
    
    // We should be on MedicationScreen. Navigate back.
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Now test Bottom Navigation Bar
    // Assuming bottom navigation icons are available
    
    // Tap Insights Tab (index 1)
    await tester.tap(find.byIcon(Icons.bar_chart));
    await tester.pumpAndSettle();
    
    // Tap Calendar Tab (index 2)
    await tester.tap(find.byIcon(Icons.calendar_today)); // Adjust icon if different
    await tester.pumpAndSettle();
    
    // Tap History Tab (index 3)
    await tester.tap(find.byIcon(Icons.history)); // Adjust icon if different
    await tester.pumpAndSettle();

    // Tap Profile Tab (index 4)
    await tester.tap(find.byIcon(Icons.person)); // Adjust icon if different
    await tester.pumpAndSettle();
    
    // Tap Home Tab (index 0)
    await tester.tap(find.byIcon(Icons.home)); // Adjust icon if different
    await tester.pumpAndSettle();

    // If no ProviderNotFoundError or other exception is thrown, the test passes
    expect(true, isTrue);
  });
}

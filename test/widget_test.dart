import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dsms_dev/features/schedule/schedule_page.dart';

void main() {
  testWidgets('SchedulePage renders title and table headers', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SchedulePage(),
      ),
    );

    // Allow mock data to resolve
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify key titles and buttons
    expect(find.text('Training Schedules'), findsOneWidget);
    expect(find.text('Add Schedule'), findsWidgets);
  });
}

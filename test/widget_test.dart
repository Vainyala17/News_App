import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newsapp_multilang/main.dart';

void main() {
  testWidgets('Language dropdown displays and switches language', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: NewsScreen()));

    // Check if dropdown exists
    expect(find.byType(DropdownButton<String>), findsOneWidget);

    // Open the dropdown
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    // Select 'Hindi' from the dropdown
    await tester.tap(find.text('Hindi').last);
    await tester.pumpAndSettle();

    // Check if any translated text appears (based on your mock translation logic)
    expect(find.textContaining('हिंदी:'), findsWidgets); // should show Hindi prefix
  });
}

// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:my_flutter_app/home_page.dart';
import 'package:my_flutter_app/app_state.dart';


void main() {
  // Tests the home page on launch and checks for "Welcome" display
  testWidgets('HomePage loads and shows Welcome text', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<ApplicationState>(
          create: (_) => ApplicationState(),
          child: HomePage(),
        ),
      ),
    );

    expect(find.text('Welcome'), findsOneWidget);
  });

  
}

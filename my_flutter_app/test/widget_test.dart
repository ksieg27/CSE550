// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:my_flutter_app/home_page.dart';
import 'package:my_flutter_app/app_state.dart';
import 'package:medication_management_module/ui/searching/view/search_medication_view.dart';
import 'package:medication_management_module/ui/searching/view_models/search_medication_view_model.dart';
import 'package:mockito/mockito.dart';


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

  testWidgets('Medication search autocomplete shows results', (WidgetTester tester) async {
    // Mock search API
    final mockResponse = [
      {
        'openfda': {
          'brand_name': ['Advil'],
          'generic_name': ['Ibuprofen']
        }
      }
    ];

    // Use fake API method so as not to hit API during testing
    search_api.searchMedications = (String query) async {
      return mockResponse;
    };
    
        await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MedicationSearchWidget(),
        ),
      ),
    );

    // Enter text
    await tester.enterText((find.byType(TextField), 'Ad');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    // Expect to find mock results
    expect(find.text('Advil'), findsOneWidget);
    expect(find.text('Ibuprofen'), findsOneWidget);
  });
}

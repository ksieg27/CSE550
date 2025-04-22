import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_app/main.dart'; // Adjust path
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  group('LoginScreen Widget Test - TC_01', () {
    testWidgets('Successful login with valid credentials', (WidgetTester tester) async {
      // Mock FirebaseAuth with a predefined user
      final user = MockUser(
        email: 'username@dummyemail.com',
      );
      final auth = MockFirebaseAuth(mockUser: user);

      // Build the widget with mocked FirebaseAuth
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EmailForm(
            auth: auth,
            action: AuthAction.signIn,
          )
        ), // Assume SignInScreen accepts an `auth` param
      ));

      // Enter email and password
      final emailField = find.byKey(Key('emailField'));
      final passwordField = find.byKey(Key('passwordField'));
      final signInButton = find.byKey(Key('signInButton'));

      await tester.enterText(emailField, 'username@dummyemail.com');
      await tester.enterText(passwordField, 'password123!');
      expect(signInButton, findsOneWidget);

       await tester.tap(signInButton);
       await tester.pump(Duration(milliseconds: 500)); // Rebuild after interaction

      // Expect navigation or success message
       expect(find.textContaining('First Name'), findsOneWidget); // Adjust depending on your success UI
      
    });
  });
}

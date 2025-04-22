/*
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
        home: SignInScreen(auth: auth), // Assume SignInScreen accepts an `auth` param
      ));

      // Enter email and password
      final emailField = find.byKey(Key('email'));
      final passwordField = find.byKey(Key('password'));
      final loginButton = find.byKey(Key('signInButton'));

      await tester.enterText(emailField, 'username@dummyemail.com');
      await tester.enterText(passwordField, 'password123!');
      await tester.tap(loginButton);
      await tester.pump(); // Rebuild after interaction

      // Expect navigation or success message
      expect(find.text('Welcome'), findsOneWidget); // Adjust depending on your success UI
    });
  });
}
*/
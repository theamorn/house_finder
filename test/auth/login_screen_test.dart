import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:house_finder/auth/forgot_password_screen.dart';
import 'package:house_finder/auth/login_screen.dart';
import 'package:house_finder/auth/register_screen.dart';
import 'package:house_finder/data/mock_api.dart';
import 'package:house_finder/providers/auth_provider.dart';

import '../helpers/pump_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    MockApi().debugReset();
  });

  testWidgets('renders pre-filled credentials, tagline, and log in button', (
    tester,
  ) async {
    await pumpApp(tester, const LoginScreen());

    expect(find.text('demo@housefinder.app'), findsOneWidget);
    expect(find.text('password123'), findsOneWidget);
    expect(find.text('Find your next home'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);

    final emailField = tester.widget<TextField>(
      find.byType(TextField).at(0),
    );
    final passwordField = tester.widget<TextField>(
      find.byType(TextField).at(1),
    );
    expect(emailField.controller!.text, 'demo@housefinder.app');
    expect(passwordField.controller!.text, 'password123');
  });

  testWidgets('toggling password visibility flips obscureText', (
    tester,
  ) async {
    await pumpApp(tester, const LoginScreen());

    TextField passwordField = tester.widget<TextField>(
      find.byType(TextField).at(1),
    );
    expect(passwordField.obscureText, isTrue);
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pumpAndSettle();

    passwordField = tester.widget<TextField>(find.byType(TextField).at(1));
    expect(passwordField.obscureText, isFalse);
    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });

  testWidgets('tapping Forgot password navigates to ForgotPasswordScreen', (
    tester,
  ) async {
    await pumpApp(tester, const LoginScreen());

    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
  });

  testWidgets('tapping Sign up navigates to RegisterScreen', (tester) async {
    await pumpApp(tester, const LoginScreen());

    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
  });

  testWidgets('successful login with demo credentials logs the user in', (
    tester,
  ) async {
    final authProvider = AuthProvider();
    await pumpApp(tester, const LoginScreen(), authProvider: authProvider);

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(authProvider.isLoggedIn, isTrue);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('failed login with wrong password shows an error SnackBar', (
    tester,
  ) async {
    final authProvider = AuthProvider();
    await pumpApp(tester, const LoginScreen(), authProvider: authProvider);

    await tester.enterText(find.byType(TextField).at(1), 'wrongpassword');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(authProvider.isLoggedIn, isFalse);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Incorrect password'), findsOneWidget);
  });
}

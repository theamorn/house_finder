// Widget tests for RegisterScreen (lib/auth/register_screen.dart).
//
// RegisterScreen talks to the MockApi() singleton directly rather than via
// AuthProvider, so we don't use test/helpers/pump_app.dart's pumpApp here.
// It also calls Navigator.of(context).pop() on success, so it must be
// pumped as a pushed route (not as MaterialApp.home directly) or pop()
// would have nothing to pop back to.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:house_finder/auth/register_screen.dart';
import 'package:house_finder/data/mock_api.dart';

/// Pumps a MaterialApp with a button that pushes RegisterScreen, then taps
/// it so RegisterScreen becomes the active (pushed) route.
Future<void> _pumpRegisterScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Finder get _nameField => find.byType(TextField).at(0);
Finder get _emailField => find.byType(TextField).at(1);
Finder get _passwordField => find.byType(TextField).at(2);
Finder get _confirmField => find.byType(TextField).at(3);

Future<void> _fillForm(
  WidgetTester tester, {
  required String name,
  required String email,
  required String password,
  required String confirm,
}) async {
  await tester.enterText(_nameField, name);
  await tester.enterText(_emailField, email);
  await tester.enterText(_passwordField, password);
  await tester.enterText(_confirmField, confirm);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    MockApi().debugReset();
  });

  testWidgets('shows an error and does not call the API when passwords do not match', (
    tester,
  ) async {
    await _pumpRegisterScreen(tester);

    await _fillForm(
      tester,
      name: 'Jane Doe',
      email: 'jane@example.com',
      password: 'password123',
      confirm: 'different123',
    );
    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Passwords do not match'), findsOneWidget);
    expect(MockApi().currentUser, isNull);
  });

  testWidgets('shows an error and does not call the API when terms are not accepted', (
    tester,
  ) async {
    await _pumpRegisterScreen(tester);

    await _fillForm(
      tester,
      name: 'Jane Doe',
      email: 'jane@example.com',
      password: 'password123',
      confirm: 'password123',
    );
    // Checkbox left unchecked.

    await tester.tap(find.widgetWithText(ElevatedButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(find.text('You must accept the terms'), findsOneWidget);
    expect(MockApi().currentUser, isNull);
  });

  testWidgets('registers successfully, pops, and shows a confirmation snack bar', (
    tester,
  ) async {
    await _pumpRegisterScreen(tester);

    final email = 'newuser+${DateTime.now().microsecondsSinceEpoch}@test.com';
    await _fillForm(
      tester,
      name: 'Jane Doe',
      email: email,
      password: 'password123',
      confirm: 'password123',
    );
    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsNothing);
    expect(find.text('Account created. Please log in.'), findsOneWidget);
    expect(MockApi().currentUser, isNotNull);
    expect(MockApi().currentUser!.email, email);
  });

  testWidgets('shows an error and does not pop when the account already exists', (
    tester,
  ) async {
    await _pumpRegisterScreen(tester);

    await _fillForm(
      tester,
      name: 'Demo User',
      email: 'demo@housefinder.app',
      password: 'password123',
      confirm: 'password123',
    );
    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(find.textContaining('already exists'), findsOneWidget);
    expect(find.byType(RegisterScreen), findsOneWidget);
  });
}

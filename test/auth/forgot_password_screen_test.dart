// Widget tests for ForgotPasswordScreen.
//
// MockApi is a singleton (lib/data/mock_api.dart), so MockApi().debugReset()
// runs in setUp before every test to avoid state leaking between tests that
// run in the same VM/isolate. sendPasswordReset() has an artificial network
// delay; tests await tester.pumpAndSettle() to let it resolve.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:house_finder/auth/forgot_password_screen.dart';
import 'package:house_finder/data/mock_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    MockApi().debugReset();
  });

  /// Pumps a harness screen with an "open" button that pushes
  /// ForgotPasswordScreen onto the Navigator stack (mirrors real usage,
  /// since "Back to login" calls Navigator.of(context).pop()).
  Future<void> pumpForgotPasswordScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
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

  testWidgets('successful send shows the confirmation view with the entered email', (
    tester,
  ) async {
    await pumpForgotPasswordScreen(tester);

    await tester.enterText(find.byType(TextField), 'demo@housefinder.app');
    await tester.tap(find.text('Send reset link'));
    await tester.pumpAndSettle();

    expect(find.text('Check your email'), findsOneWidget);
    expect(find.textContaining('demo@housefinder.app'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('failed send shows an inline error and stays on the form', (tester) async {
    await pumpForgotPasswordScreen(tester);

    await tester.enterText(find.byType(TextField), 'nobody@nowhere.com');
    await tester.tap(find.text('Send reset link'));
    await tester.pumpAndSettle();

    expect(find.textContaining('No account found'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Check your email'), findsNothing);
  });

  testWidgets('"Back to login" pops the screen after a successful send', (tester) async {
    await pumpForgotPasswordScreen(tester);

    await tester.enterText(find.byType(TextField), 'demo@housefinder.app');
    await tester.tap(find.text('Send reset link'));
    await tester.pumpAndSettle();

    expect(find.text('Back to login'), findsOneWidget);

    await tester.tap(find.text('Back to login'));
    await tester.pumpAndSettle();

    expect(find.byType(ForgotPasswordScreen), findsNothing);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:house_finder/data/mock_api.dart';
import 'package:house_finder/providers/auth_provider.dart';

const demoEmail = 'demo@housefinder.app';
const demoPassword = 'password123';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    MockApi().debugReset();
  });

  group('AuthProvider.login', () {
    test('succeeds with seeded demo account', () async {
      final provider = AuthProvider();
      var notifyCount = 0;
      provider.addListener(() => notifyCount++);

      final result = await provider.login(demoEmail, demoPassword);

      expect(result, isTrue);
      expect(provider.isLoggedIn, isTrue);
      expect(provider.user, isNotNull);
      expect(provider.user!.email, demoEmail);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
      expect(notifyCount, greaterThan(0));
    });

    test('fails with wrong password', () async {
      final provider = AuthProvider();

      final result = await provider.login(demoEmail, 'wrong-password');

      expect(result, isFalse);
      expect(provider.isLoggedIn, isFalse);
      expect(provider.user, isNull);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNotNull);
      expect(provider.error, isNot(contains('Exception')));
      expect(provider.error, contains('Incorrect password'));
    });

    test('fails with unknown email', () async {
      final provider = AuthProvider();

      final result = await provider.login('nobody@nowhere.com', 'whatever');

      expect(result, isFalse);
      expect(provider.isLoggedIn, isFalse);
      expect(provider.user, isNull);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNotNull);
      expect(provider.error, isNot(contains('Exception')));
      expect(provider.error, contains('No account found'));
    });

    test('isLoading is true while the request is pending and false after', () async {
      final provider = AuthProvider();

      expect(provider.isLoading, isFalse);

      final future = provider.login(demoEmail, demoPassword);

      // AuthProvider.login runs synchronously up until the first await
      // inside MockApi (an artificial Future.delayed), so isLoading should
      // already be flipped to true before we await the returned future.
      expect(provider.isLoading, isTrue);

      await future;

      expect(provider.isLoading, isFalse);
    });

    test('isLoading transitions true then false on failure too', () async {
      final provider = AuthProvider();
      final loadingStates = <bool>[];
      provider.addListener(() => loadingStates.add(provider.isLoading));

      await provider.login(demoEmail, 'wrong-password');

      expect(loadingStates, isNotEmpty);
      expect(loadingStates.first, isTrue);
      expect(loadingStates.last, isFalse);
    });
  });

  group('AuthProvider.register', () {
    test('succeeds with a new unique account', () async {
      final provider = AuthProvider();
      final uniqueEmail = 'newuser+${DateTime.now().microsecondsSinceEpoch}@test.com';

      final result = await provider.register(uniqueEmail, 'somePassword1', 'New User');

      expect(result, isTrue);
      expect(provider.isLoggedIn, isTrue);
      expect(provider.user, isNotNull);
      expect(provider.user!.email, uniqueEmail);
      expect(provider.user!.fullName, 'New User');
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('fails when the email is already registered', () async {
      final provider = AuthProvider();

      final result = await provider.register(demoEmail, 'somePassword1', 'Demo Duplicate');

      expect(result, isFalse);
      expect(provider.isLoggedIn, isFalse);
      expect(provider.user, isNull);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNotNull);
      expect(provider.error, isNot(contains('Exception')));
      expect(provider.error, contains('already exists'));
    });
  });

  group('AuthProvider.sendPasswordReset', () {
    test('succeeds for the seeded demo email', () async {
      final provider = AuthProvider();

      final result = await provider.sendPasswordReset(demoEmail);

      expect(result, isTrue);
      expect(provider.error, isNull);
      expect(provider.isLoading, isFalse);
    });

    test('fails for an unknown email', () async {
      final provider = AuthProvider();

      final result = await provider.sendPasswordReset('nobody@nowhere.com');

      expect(result, isFalse);
      expect(provider.error, isNotNull);
      expect(provider.error, isNot(contains('Exception')));
      expect(provider.isLoading, isFalse);
    });
  });

  group('AuthProvider.logout', () {
    test('clears user and logged-in state after a successful login', () async {
      final provider = AuthProvider();
      await provider.login(demoEmail, demoPassword);
      expect(provider.isLoggedIn, isTrue);

      var notified = false;
      provider.addListener(() => notified = true);

      await provider.logout();

      expect(provider.isLoggedIn, isFalse);
      expect(provider.user, isNull);
      expect(notified, isTrue);
    });
  });

  group('AuthProvider.clearError', () {
    test('resets error to null and notifies listeners', () async {
      final provider = AuthProvider();
      await provider.login(demoEmail, 'wrong-password');
      expect(provider.error, isNotNull);

      var notified = false;
      provider.addListener(() => notified = true);

      provider.clearError();

      expect(provider.error, isNull);
      expect(notified, isTrue);
    });
  });
}

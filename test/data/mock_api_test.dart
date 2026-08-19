// Unit tests for MockApi.
//
// MockApi is a singleton, so every test resets shared state via
// MockApi().debugReset() in setUp to avoid leakage between tests that run
// in the same VM/isolate. fetchNews() has a built-in ~1/4 random failure
// rate; tests that need a reliable success path set
// debugDisableRandomFailures = true first.

import 'package:flutter_test/flutter_test.dart';
import 'package:house_finder/data/mock_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    MockApi().debugReset();
  });

  group('fetchProperties', () {
    test('returns a non-empty list', () async {
      final api = MockApi();
      final properties = await api.fetchProperties();
      expect(properties, isNotEmpty);
    });

    test('type: house filters to only house-type entries', () async {
      final api = MockApi();
      final houses = await api.fetchProperties(type: 'house');
      expect(houses, isNotEmpty);
      expect(houses.every((p) => p.type == 'house'), isTrue);
      // Fixture data (assets/fixtures/properties.json) has exactly 6 houses:
      // p-001, p-004, p-007, p-010, p-013, p-016.
      expect(houses.length, 6);
      expect(houses.map((p) => p.id), containsAll(<String>[
        'p-001',
        'p-004',
        'p-007',
        'p-010',
        'p-013',
        'p-016',
      ]));
    });

    test('type: all returns the full unfiltered list', () async {
      final api = MockApi();
      final all = await api.fetchProperties();
      final explicitAll = await api.fetchProperties(type: 'all');
      expect(explicitAll.length, all.length);
    });

    test('type: null returns the full unfiltered list', () async {
      final api = MockApi();
      final all = await api.fetchProperties();
      final nullType = await api.fetchProperties(type: null);
      expect(nullType.length, all.length);
      // Sanity check the fixture actually has more than one type present.
      final types = all.map((p) => p.type).toSet();
      expect(types.length, greaterThan(1));
    });
  });

  group('fetchProperty', () {
    test('returns the correct property by id', () async {
      final api = MockApi();
      final property = await api.fetchProperty('p-001');
      expect(property.id, 'p-001');
      expect(property.title, 'Modern 3-Bed House with Garden');
      expect(property.type, 'house');
    });

    test('throws for an unknown id', () async {
      final api = MockApi();
      expect(
        () => api.fetchProperty('does-not-exist'),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('fetchNews', () {
    test('returns a non-empty list matching the fixture length', () async {
      final api = MockApi();
      api.debugDisableRandomFailures = true;
      final news = await api.fetchNews();
      expect(news, isNotEmpty);
      // assets/fixtures/news.json has exactly 7 entries.
      expect(news.length, 7);
    });
  });

  group('fetchViewings', () {
    test('returns a non-empty list matching the fixture length', () async {
      final api = MockApi();
      final viewings = await api.fetchViewings();
      expect(viewings, isNotEmpty);
      // assets/fixtures/viewings.json has exactly 5 entries.
      expect(viewings.length, 5);
    });
  });

  group('scheduleViewing', () {
    test('returns a pending viewing with the passed-in fields and appends '
        'it to fetchViewings()', () async {
      final api = MockApi();
      final before = await api.fetchViewings();
      final beforeCount = before.length;

      final when = DateTime(2026, 9, 1, 10, 30);
      final viewing = await api.scheduleViewing(
        propertyId: 'p-005',
        propertyTitle: '1-Bed Condo, Ratchathewi',
        propertyImageUrl: 'https://images.housefinder.local/p-005.jpg',
        when: when,
        notes: 'Bring floor plan',
      );

      expect(viewing.status, 'pending');
      expect(viewing.propertyId, 'p-005');
      expect(viewing.propertyTitle, '1-Bed Condo, Ratchathewi');
      expect(
        viewing.propertyImageUrl,
        'https://images.housefinder.local/p-005.jpg',
      );
      expect(viewing.scheduledAt, when.toIso8601String());
      expect(viewing.notes, 'Bring floor plan');

      final after = await api.fetchViewings();
      expect(after.length, beforeCount + 1);
      expect(after.map((v) => v.id), contains(viewing.id));
    });
  });

  group('updateViewingStatus', () {
    test('updates an existing viewing status and it sticks', () async {
      final api = MockApi();
      final seeded = await api.fetchViewings();
      final target = seeded.firstWhere((v) => v.id == 'v-002');
      expect(target.status, 'pending');

      final updated = await api.updateViewingStatus('v-002', 'confirmed');
      expect(updated.status, 'confirmed');

      final after = await api.fetchViewings();
      final refetched = after.firstWhere((v) => v.id == 'v-002');
      expect(refetched.status, 'confirmed');
    });
  });

  group('rescheduleViewing', () {
    test('changes scheduledAt and resets status to pending', () async {
      final api = MockApi();
      await api.fetchViewings();

      // v-001 starts as 'confirmed' in the fixture; reschedule should reset
      // it to 'pending'.
      final newWhen = DateTime(2026, 10, 5, 15, 0);
      final updated = await api.rescheduleViewing('v-001', newWhen);
      expect(updated.scheduledAt, newWhen.toIso8601String());
      expect(updated.status, 'pending');

      final after = await api.fetchViewings();
      final refetched = after.firstWhere((v) => v.id == 'v-001');
      expect(refetched.scheduledAt, newWhen.toIso8601String());
      expect(refetched.status, 'pending');
    });
  });

  group('login', () {
    test('succeeds with seeded demo account and sets currentUser', () async {
      final api = MockApi();
      final user = await api.login('demo@housefinder.app', 'password123');
      expect(user.email, 'demo@housefinder.app');
      expect(api.currentUser, isNotNull);
      expect(api.currentUser!.email, 'demo@housefinder.app');
    });

    test('throws with "Incorrect password" for wrong password', () async {
      final api = MockApi();
      expect(
        () => api.login('demo@housefinder.app', 'wrong-password'),
        throwsA(
          predicate((e) => e.toString().contains('Incorrect password')),
        ),
      );
    });

    test('throws with "No account found" for unknown email', () async {
      final api = MockApi();
      expect(
        () => api.login('nobody@example.com', 'password123'),
        throwsA(
          predicate((e) => e.toString().contains('No account found')),
        ),
      );
    });
  });

  group('register', () {
    test('creates a new account and sets currentUser', () async {
      final api = MockApi();
      final user = await api.register(
        'newuser@example.com',
        'supersecret',
        'New User',
      );
      expect(user.email, 'newuser@example.com');
      expect(user.fullName, 'New User');
      expect(api.currentUser, isNotNull);
      expect(api.currentUser!.email, 'newuser@example.com');

      // The new account can now be used to log in.
      await api.logout();
      final loggedIn = await api.login('newuser@example.com', 'supersecret');
      expect(loggedIn.email, 'newuser@example.com');
    });

    test('throws with "already exists" for an existing email', () async {
      final api = MockApi();
      expect(
        () => api.register(
          'demo@housefinder.app',
          'whatever',
          'Someone Else',
        ),
        throwsA(
          predicate((e) => e.toString().contains('already exists')),
        ),
      );
    });
  });

  group('sendPasswordReset', () {
    test('succeeds silently for a known account', () async {
      final api = MockApi();
      await expectLater(
        api.sendPasswordReset('demo@housefinder.app'),
        completes,
      );
    });

    test('throws for an unknown account', () async {
      final api = MockApi();
      expect(
        () => api.sendPasswordReset('nobody@example.com'),
        throwsA(anything),
      );
    });
  });

  group('logout', () {
    test('clears currentUser to null', () async {
      final api = MockApi();
      await api.login('demo@housefinder.app', 'password123');
      expect(api.currentUser, isNotNull);

      await api.logout();
      expect(api.currentUser, isNull);
    });
  });
}

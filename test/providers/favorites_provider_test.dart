import 'package:flutter_test/flutter_test.dart';
import 'package:house_finder/data/mock_api.dart';
import 'package:house_finder/providers/favorites_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String propertyIdA;
  late String propertyIdB;

  setUpAll(() async {
    // Grab two real property ids from the fixtures via MockApi so the
    // favorited ids in these tests always correspond to real properties.
    final properties = await MockApi().fetchProperties();
    expect(properties.length, greaterThanOrEqualTo(2));
    propertyIdA = properties[0].id;
    propertyIdB = properties[1].id;
    MockApi().debugReset();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    MockApi().debugReset();
  });

  group('FavoritesProvider.load', () {
    test('with no prior stored favorites results in empty state', () async {
      final provider = FavoritesProvider();
      var notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.load();

      expect(provider.favoriteIds, isEmpty);
      expect(provider.favorites, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.count, 0);
      expect(notifyCount, greaterThan(0));
    });

    test('with pre-seeded SharedPreferences hydrates ids and favorites', () async {
      SharedPreferences.setMockInitialValues({
        'favorite_ids': [propertyIdA],
      });
      final provider = FavoritesProvider();

      await provider.load();

      expect(provider.favoriteIds, contains(propertyIdA));
      expect(provider.favorites.map((p) => p.id), contains(propertyIdA));
      expect(provider.count, provider.favoriteIds.length);
      expect(provider.isLoading, isFalse);
    });
  });

  group('FavoritesProvider.toggle', () {
    test('adding a not-yet-favorited id updates state and persists it', () async {
      final provider = FavoritesProvider();
      await provider.load();
      var notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.toggle(propertyIdA);

      expect(provider.favoriteIds, contains(propertyIdA));
      expect(provider.isFavorite(propertyIdA), isTrue);
      expect(provider.favorites.map((p) => p.id), contains(propertyIdA));
      expect(provider.count, provider.favoriteIds.length);
      expect(notifyCount, greaterThan(0));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('favorite_ids'), contains(propertyIdA));
    });

    test('toggling the same id again removes it', () async {
      final provider = FavoritesProvider();
      await provider.load();
      await provider.toggle(propertyIdA);
      expect(provider.isFavorite(propertyIdA), isTrue);

      var notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.toggle(propertyIdA);

      expect(provider.favoriteIds, isNot(contains(propertyIdA)));
      expect(provider.isFavorite(propertyIdA), isFalse);
      expect(provider.favorites.map((p) => p.id), isNot(contains(propertyIdA)));
      expect(provider.count, 0);
      expect(notifyCount, greaterThan(0));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('favorite_ids'), isNot(contains(propertyIdA)));
    });

    test('supports toggling multiple ids independently', () async {
      final provider = FavoritesProvider();
      await provider.load();

      await provider.toggle(propertyIdA);
      await provider.toggle(propertyIdB);

      expect(provider.favoriteIds, containsAll([propertyIdA, propertyIdB]));
      expect(provider.count, 2);

      await provider.toggle(propertyIdA);

      expect(provider.favoriteIds, contains(propertyIdB));
      expect(provider.favoriteIds, isNot(contains(propertyIdA)));
      expect(provider.count, 1);
    });
  });

  group('FavoritesProvider.clear', () {
    test('empties favorites and removes persisted key', () async {
      final provider = FavoritesProvider();
      await provider.load();
      await provider.toggle(propertyIdA);
      await provider.toggle(propertyIdB);
      expect(provider.count, 2);

      var notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.clear();

      expect(provider.favoriteIds, isEmpty);
      expect(provider.favorites, isEmpty);
      expect(provider.count, 0);
      expect(notifyCount, greaterThan(0));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('favorite_ids'), isFalse);
    });
  });

  group('FavoritesProvider.count', () {
    test('matches favoriteIds.length at various points', () async {
      final provider = FavoritesProvider();
      await provider.load();
      expect(provider.count, provider.favoriteIds.length);
      expect(provider.count, 0);

      await provider.toggle(propertyIdA);
      expect(provider.count, provider.favoriteIds.length);
      expect(provider.count, 1);

      await provider.toggle(propertyIdB);
      expect(provider.count, provider.favoriteIds.length);
      expect(provider.count, 2);

      await provider.toggle(propertyIdA);
      expect(provider.count, provider.favoriteIds.length);
      expect(provider.count, 1);

      await provider.clear();
      expect(provider.count, provider.favoriteIds.length);
      expect(provider.count, 0);
    });
  });
}

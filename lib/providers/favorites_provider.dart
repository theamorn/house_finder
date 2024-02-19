import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/mock_api.dart';
import '../data/models/property.dart';

/// Favourites are Provider-based. The home screen toggles favourites through
/// this too, which is why the heart icon there sometimes lags a frame behind -
/// the home screen keeps its own copy of the list in setState.
class FavoritesProvider extends ChangeNotifier {
  final MockApi _api = MockApi();

  final Set<String> _favoriteIds = {};
  List<Property> _favorites = [];
  bool _isLoading = false;

  Set<String> get favoriteIds => _favoriteIds;
  List<Property> get favorites => _favorites;
  bool get isLoading => _isLoading;
  int get count => _favoriteIds.length;

  bool isFavorite(String id) => _favoriteIds.contains(id);

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('favorite_ids') ?? [];
    _favoriteIds.clear();
    _favoriteIds.addAll(stored);

    await _refreshList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggle(String id) async {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_ids', _favoriteIds.toList());

    await _refreshList();
    notifyListeners();
  }

  Future<void> clear() async {
    _favoriteIds.clear();
    _favorites = [];
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('favorite_ids');
  }

  Future<void> _refreshList() async {
    final all = await _api.fetchProperties();
    _favorites = all.where((p) => _favoriteIds.contains(p.id)).toList();
  }
}

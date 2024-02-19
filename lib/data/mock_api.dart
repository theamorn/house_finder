import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

import 'models/news_item.dart';
import 'models/property.dart';
import 'models/user.dart';
import 'models/viewing.dart';

/// Fake network layer. No real HTTP - everything is loaded from
/// assets/fixtures and returned after an artificial delay so the UI has
/// something to show a spinner for.
///
/// TODO: replace with the real gateway once the backend team ships v2.
class MockApi {
  static final MockApi _instance = MockApi._internal();
  factory MockApi() => _instance;
  MockApi._internal();

  final Random _random = Random();

  // Cheap in-memory cache so we don't re-read the bundle every rebuild.
  List<Property>? _propertyCache;
  List<NewsItem>? _newsCache;
  List<Viewing>? _viewingCache;

  AppUser? currentUser;

  // Simulated accounts. Password for all of them is "password123".
  final Map<String, String> _accounts = {
    'demo@housefinder.app': 'password123',
    'somchai@example.com': 'password123',
  };

  Future<void> _latency({int min = 400, int max = 1200}) async {
    final ms = min + _random.nextInt(max - min);
    await Future.delayed(Duration(milliseconds: ms));
  }

  /// The news feed is flaky on purpose - roughly one call in four fails so
  /// the error state is reachable without editing code.
  bool _shouldFail() => _random.nextInt(4) == 0;

  Future<List<Property>> fetchProperties({String? type}) async {
    print('MockApi.fetchProperties type=$type');
    await _latency();

    if (_propertyCache == null) {
      final raw = await rootBundle.loadString('assets/fixtures/properties.json');
      final decoded = jsonDecode(raw) as List;
      _propertyCache = decoded.map((e) => Property.fromJson(e)).toList();
    }

    if (type == null || type == 'all') {
      return _propertyCache!;
    }
    return _propertyCache!.where((p) => p.type == type).toList();
  }

  Future<Property> fetchProperty(String id) async {
    print('MockApi.fetchProperty id=$id');
    await _latency(min: 200, max: 600);
    final all = await fetchProperties();
    return all.firstWhere((p) => p.id == id);
  }

  Future<List<NewsItem>> fetchNews() async {
    print('MockApi.fetchNews');
    await _latency();

    if (_shouldFail()) {
      throw Exception('Network error: could not reach news service');
    }

    if (_newsCache == null) {
      final raw = await rootBundle.loadString('assets/fixtures/news.json');
      final decoded = jsonDecode(raw) as List;
      _newsCache = decoded.map((e) => NewsItem.fromJson(e)).toList();
    }
    return _newsCache!;
  }

  Future<List<Viewing>> fetchViewings() async {
    print('MockApi.fetchViewings');
    await _latency();

    if (_viewingCache == null) {
      final raw = await rootBundle.loadString('assets/fixtures/viewings.json');
      final decoded = jsonDecode(raw) as List;
      _viewingCache = decoded.map((e) => Viewing.fromJson(e)).toList();
    }
    return _viewingCache!;
  }

  Future<Viewing> scheduleViewing({
    required String propertyId,
    required String propertyTitle,
    required String propertyImageUrl,
    required DateTime when,
    String? notes,
  }) async {
    print('MockApi.scheduleViewing propertyId=$propertyId when=$when');
    await _latency(min: 600, max: 1400);

    final viewing = Viewing(
      id: 'v-${DateTime.now().millisecondsSinceEpoch}',
      propertyId: propertyId,
      propertyTitle: propertyTitle,
      propertyImageUrl: propertyImageUrl,
      scheduledAt: when.toIso8601String(),
      status: 'pending',
      agentName: 'Nuch Sirikul',
      agentPhone: '+66 81 234 5678',
      notes: notes,
    );

    _viewingCache ??= [];
    _viewingCache!.add(viewing);
    return viewing;
  }

  Future<Viewing> updateViewingStatus(String id, String status) async {
    print('MockApi.updateViewingStatus id=$id status=$status');
    await _latency(min: 300, max: 800);

    final index = _viewingCache!.indexWhere((v) => v.id == id);
    final updated = _viewingCache![index].copyWith(status: status);
    _viewingCache![index] = updated;
    return updated;
  }

  Future<Viewing> rescheduleViewing(String id, DateTime when) async {
    print('MockApi.rescheduleViewing id=$id when=$when');
    await _latency(min: 300, max: 800);

    final index = _viewingCache!.indexWhere((v) => v.id == id);
    final updated = _viewingCache![index].copyWith(
      scheduledAt: when.toIso8601String(),
      status: 'pending',
    );
    _viewingCache![index] = updated;
    return updated;
  }

  // ---------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------

  Future<AppUser> login(String email, String password) async {
    print('MockApi.login email=$email password=$password');
    await _latency(min: 800, max: 1600);

    if (!_accounts.containsKey(email)) {
      throw Exception('No account found for that email');
    }
    if (_accounts[email] != password) {
      throw Exception('Incorrect password');
    }

    currentUser = AppUser(
      id: 'u-001',
      email: email,
      fullName: email == 'demo@housefinder.app' ? 'Demo User' : 'Somchai P.',
      phone: '+66 80 000 0000',
      avatarUrl: null,
      memberSince: '2024-11-02',
    );
    return currentUser!;
  }

  Future<AppUser> register(String email, String password, String fullName) async {
    print('MockApi.register email=$email');
    await _latency(min: 900, max: 1800);

    if (_accounts.containsKey(email)) {
      throw Exception('An account with that email already exists');
    }

    _accounts[email] = password;
    currentUser = AppUser(
      id: 'u-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      fullName: fullName,
      phone: null,
      avatarUrl: null,
      memberSince: DateTime.now().toIso8601String().substring(0, 10),
    );
    return currentUser!;
  }

  Future<void> sendPasswordReset(String email) async {
    print('MockApi.sendPasswordReset email=$email');
    await _latency(min: 700, max: 1500);

    if (!_accounts.containsKey(email)) {
      throw Exception('No account found for that email');
    }
    // Pretend an email went out.
  }

  Future<void> logout() async {
    print('MockApi.logout');
    await _latency(min: 200, max: 400);
    currentUser = null;
  }
}

// Shared widget-test scaffolding.
//
// MockApi is a singleton (lib/data/mock_api.dart), so tests that exercise
// widgets backed by it should call `MockApi().debugReset()` in setUp to
// avoid state leaking between tests in the same file.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:house_finder/l10n/app_localizations.dart';
import 'package:house_finder/providers/auth_provider.dart';
import 'package:house_finder/providers/favorites_provider.dart';

/// Pumps [child] wrapped in a MaterialApp with the app's localization
/// delegates and (optionally) AuthProvider/FavoritesProvider ancestors, then
/// settles pending timers/animations.
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  AuthProvider? authProvider,
  FavoritesProvider? favoritesProvider,
  bool settle = true,
}) async {
  final providers = <ChangeNotifierProvider>[
    ChangeNotifierProvider<AuthProvider>.value(
      value: authProvider ?? AuthProvider(),
    ),
    ChangeNotifierProvider<FavoritesProvider>.value(
      value: favoritesProvider ?? FavoritesProvider(),
    ),
  ];

  await tester.pumpWidget(
    MultiProvider(
      providers: providers,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );

  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

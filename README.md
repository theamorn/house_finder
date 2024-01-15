# HouseFinder

Property search app. Houses, condos and apartments, Bangkok only for now.

## Getting started

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

Log in with `demo@housefinder.app` / `password123`. There is no real backend —
`lib/data/mock_api.dart` reads from `assets/fixtures/` and adds a fake delay.

## Structure

```
lib/
  auth/            login, register, forgot password
  core/            theme, shared formatters
  data/            models + MockApi
  features/        profile
  pages/           favourites, news
  providers/       auth + favourites (ChangeNotifier)
  screens/         explore / home
  views/           viewings
```

## Tests

```bash
flutter test
```

## Release

Signing config lives in `android/key.properties`. Ask Bank for the keystore.

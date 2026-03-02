// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HouseFinder';

  @override
  String get tagline => 'Find your next home';

  @override
  String get logIn => 'Log in';

  @override
  String get signUp => 'Sign up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get exploreTab => 'Explore';

  @override
  String get savedTab => 'Saved';

  @override
  String get newsTab => 'News';

  @override
  String get viewingsTab => 'Viewings';

  @override
  String get profileTab => 'Profile';
}

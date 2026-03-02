// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'HouseFinder';

  @override
  String get tagline => 'ค้นหาบ้านหลังต่อไปของคุณ';

  @override
  String get logIn => 'เข้าสู่ระบบ';

  @override
  String get signUp => 'สมัครสมาชิก';

  @override
  String get email => 'อีเมล';

  @override
  String get password => 'รหัสผ่าน';

  @override
  String get forgotPassword => 'ลืมรหัสผ่าน?';

  @override
  String get noAccount => 'ยังไม่มีบัญชี?';

  @override
  String get exploreTab => 'ค้นหา';

  @override
  String get savedTab => 'บันทึกไว้';

  @override
  String get newsTab => 'ข่าวสาร';

  @override
  String get viewingsTab => 'นัดชม';

  @override
  String get profileTab => 'โปรไฟล์';
}

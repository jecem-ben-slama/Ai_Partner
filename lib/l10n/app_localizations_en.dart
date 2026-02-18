// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AI Assistant';

  @override
  String get settings => 'Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get homeLabel => 'Home';

  @override
  String get helpLabel => 'Help';

  @override
  String get aboutLabel => 'About';

  @override
  String get settingsLabel => 'Settings';

  @override
  String get resetTitle => 'Restore Defaults';

  @override
  String get resetWarning => 'This will reset all your preferences.';

  @override
  String get cancel => 'cancel';

  @override
  String get confirm => 'confirm';
}

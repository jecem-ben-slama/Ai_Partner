import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Partner'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @homeLabel.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeLabel;

  /// No description provided for @helpLabel.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpLabel;

  /// No description provided for @aboutLabel.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutLabel;

  /// No description provided for @bookmarkLabel.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get bookmarkLabel;

  /// No description provided for @settingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsLabel;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore Defaults'**
  String get resetTitle;

  /// No description provided for @resetWarning.
  ///
  /// In en, this message translates to:
  /// **'This will reset all your preferences.'**
  String get resetWarning;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @textExtraction.
  ///
  /// In en, this message translates to:
  /// **'Text Extraction'**
  String get textExtraction;

  /// No description provided for @textExtractionLabel.
  ///
  /// In en, this message translates to:
  /// **'Upload an image to identify text or QR codes'**
  String get textExtractionLabel;

  /// No description provided for @textTranslation.
  ///
  /// In en, this message translates to:
  /// **'Text Translation'**
  String get textTranslation;

  /// No description provided for @galleryLabel.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get galleryLabel;

  /// No description provided for @cameraLabel.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraLabel;

  /// No description provided for @translationLabel.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get translationLabel;

  /// No description provided for @textHint.
  ///
  /// In en, this message translates to:
  /// **'Type or paste text here'**
  String get textHint;

  /// No description provided for @selectZoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Zone'**
  String get selectZoneLabel;

  /// No description provided for @clearHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Saved?'**
  String get clearHistoryTitle;

  /// No description provided for @clearHistoryMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all saved scans.'**
  String get clearHistoryMessage;

  /// No description provided for @ttsLabel.
  ///
  /// In en, this message translates to:
  /// **'Text To Speech'**
  String get ttsLabel;

  /// No description provided for @speedLabel.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speedLabel;

  /// No description provided for @detectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Detected'**
  String get detectedLabel;

  /// No description provided for @searchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search saved items'**
  String get searchLabel;

  /// No description provided for @allscansLabel.
  ///
  /// In en, this message translates to:
  /// **'All scans'**
  String get allscansLabel;

  /// No description provided for @favoritesLabel.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesLabel;

  /// No description provided for @translatetoLabel.
  ///
  /// In en, this message translates to:
  /// **'Translate to'**
  String get translatetoLabel;

  /// No description provided for @picktarget.
  ///
  /// In en, this message translates to:
  /// **'Pick a target language'**
  String get picktarget;

  /// No description provided for @copiedLabel.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copiedLabel;

  /// No description provided for @saveitemLabel.
  ///
  /// In en, this message translates to:
  /// **'Save Item'**
  String get saveitemLabel;

  /// No description provided for @clearscanTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Saved?'**
  String get clearscanTitle;

  /// No description provided for @clearscanMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete this saved scans.'**
  String get clearscanMessage;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @detailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsLabel;

  /// No description provided for @welcomeText.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your AI Partner'**
  String get welcomeText;

  /// No description provided for @genericerrorLabel.
  ///
  /// In en, this message translates to:
  /// **'Something Went Wrong!'**
  String get genericerrorLabel;

  /// No description provided for @renameScanLabel.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get renameScanLabel;

  /// No description provided for @emptyVision.
  ///
  /// In en, this message translates to:
  /// **'No text or barcodes detected. Try a clearer photo.'**
  String get emptyVision;

  /// No description provided for @visionError.
  ///
  /// In en, this message translates to:
  /// **'AI failed to process image:'**
  String get visionError;

  /// No description provided for @nothingFound.
  ///
  /// In en, this message translates to:
  /// **'Nothing Found'**
  String get nothingFound;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data found in image.'**
  String get noData;

  /// No description provided for @analysingLabel.
  ///
  /// In en, this message translates to:
  /// **'Analyzing Image...'**
  String get analysingLabel;

  /// No description provided for @loadHistoryError.
  ///
  /// In en, this message translates to:
  /// **'Could not load history.'**
  String get loadHistoryError;

  /// No description provided for @saveError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save.'**
  String get saveError;

  /// No description provided for @deleteError.
  ///
  /// In en, this message translates to:
  /// **'Delete failed.'**
  String get deleteError;

  /// No description provided for @clearHistoryError.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear history.'**
  String get clearHistoryError;

  /// No description provided for @identifyError.
  ///
  /// In en, this message translates to:
  /// **'Could not identify language.'**
  String get identifyError;

  /// No description provided for @translationError.
  ///
  /// In en, this message translates to:
  /// **'Failed to translate.'**
  String get translationError;

  /// No description provided for @translatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Translating...'**
  String get translatingLabel;

  /// No description provided for @downloadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get downloadingLabel;

  /// No description provided for @appearanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceLabel;

  /// No description provided for @systemLabel.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemLabel;

  /// No description provided for @interactionLabel.
  ///
  /// In en, this message translates to:
  /// **'Interaction'**
  String get interactionLabel;

  /// No description provided for @hapticLabel.
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticLabel;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @med.
  ///
  /// In en, this message translates to:
  /// **'Med'**
  String get med;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @soundEffectsLabel.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffectsLabel;

  /// No description provided for @notificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

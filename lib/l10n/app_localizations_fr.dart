// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Assistant IA';

  @override
  String get settings => 'Paramètres';

  @override
  String get darkMode => 'Mode Sombre';

  @override
  String get language => 'Langue';

  @override
  String get homeLabel => 'Accueil';

  @override
  String get helpLabel => 'Aide';

  @override
  String get aboutLabel => 'À Propos';

  @override
  String get bookmarkLabel => 'Favoris';

  @override
  String get settingsLabel => 'Paramètres';

  @override
  String get resetTitle => 'Réinitialiser';

  @override
  String get resetWarning => 'Cela réinitialisera toutes vos préférences.';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get textExtraction => 'Extraction de texte';

  @override
  String get textExtractionLabel =>
      'Téléchargez une image pour identifier du texte ou des codes QR';

  @override
  String get textTranslation => 'Traduction de texte';

  @override
  String get galleryLabel => 'Galerie';

  @override
  String get cameraLabel => 'Appareil photo';

  @override
  String get translationLabel => 'Traduire';

  @override
  String get translationHint => 'Saisissez ou collez du texte ici';

  @override
  String get selectZoneLabel => 'Choisir une zone';

  @override
  String get clearHistoryTitle => 'Effacer les éléments enregistrés ?';

  @override
  String get clearHistoryMessage =>
      'Cela supprimera définitivement tous les scans enregistrés.';
}

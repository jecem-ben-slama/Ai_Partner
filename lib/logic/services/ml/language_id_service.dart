import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';

class LanguageIdService {
  final _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);

  Future<String> identifyLanguage(String text) async {
    try {
      final String languageCode = await _languageIdentifier.identifyLanguage(
        text,
      );

      if (languageCode == 'und') {
        return 'en';
      }

      return languageCode;
    } catch (e) {
      return 'en';
    }
  }


  Future<List<IdentifiedLanguage>> identifyPossibleLanguages(
    String text,
  ) async {
    return await _languageIdentifier.identifyPossibleLanguages(text);
  }

  void dispose() {
    _languageIdentifier.close();
  }
}

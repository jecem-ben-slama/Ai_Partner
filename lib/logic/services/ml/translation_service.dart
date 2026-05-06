import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  final _modelManager = OnDeviceTranslatorModelManager();
  OnDeviceTranslator? _translator;

  /// Translates text using BCP-47 language codes (e.g., 'en', 'ar')
  Future<String> translate({
    required String text,
    required String sourceCode,
    required String targetCode,
  }) async {
    try {
      final source =
          BCP47Code.fromRawValue(sourceCode) ?? TranslateLanguage.english;
      final target =
          BCP47Code.fromRawValue(targetCode) ?? TranslateLanguage.english;

      final bool isDownloaded = await _modelManager.isModelDownloaded(
        target.bcpCode,
      );
      if (!isDownloaded) {
        await _modelManager.downloadModel(target.bcpCode);
      }

      _translator = OnDeviceTranslator(
        sourceLanguage: source,
        targetLanguage: target,
      );

      final String result = await _translator!.translateText(text);
      await _close();

      return result;
    } catch (e) {
      return "Translation Error";
    }
  }

  Future<bool> isLanguageDownloaded(String langCode) async {
    final lang = BCP47Code.fromRawValue(langCode) ?? TranslateLanguage.english;
    return await _modelManager.isModelDownloaded(lang.bcpCode);
  }

  Future<void> _close() async {
    await _translator?.close();
    _translator = null;
  }
}

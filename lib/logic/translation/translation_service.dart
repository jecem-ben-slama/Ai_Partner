import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationService {
  // Singleton pattern to access the service anywhere
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  final _modelManager = OnDeviceTranslatorModelManager();
  OnDeviceTranslator? _translator;

  /// Translates text after ensuring the required language model is downloaded.
  Future<String> translate({
    required String text,
    required TranslateLanguage source,
    required TranslateLanguage target,
  }) async {
    try {
      // 1. Ensure the target model is available
      final bool isDownloaded = await _modelManager.isModelDownloaded(
        target.bcpCode,
      );
      if (!isDownloaded) {
        // This takes a few moments (approx 30MB)
        await _modelManager.downloadModel(target.bcpCode);
      }

      // 2. Initialize the translator for these specific languages
      _translator = OnDeviceTranslator(
        sourceLanguage: source,
        targetLanguage: target,
      );

      // 3. Perform the translation
      final String result = await _translator!.translateText(text);

      // 4. Clean up resources immediately
      await _close();

      return result;
    } catch (e) {
      return "Translation Error: ${e.toString()}";
    }
  }

  /// Checks if a language model is already on the device
  Future<bool> isLanguageDownloaded(TranslateLanguage language) async {
    return await _modelManager.isModelDownloaded(language.bcpCode);
  }

  /// Manual download for pre-loading models in the background
  Future<void> downloadLanguage(TranslateLanguage language) async {
    await _modelManager.downloadModel(language.bcpCode);
  }

  Future<void> _close() async {
    await _translator?.close();
    _translator = null;
  }
}

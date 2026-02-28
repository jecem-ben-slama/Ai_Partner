import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'translation_state.dart';
import 'package:ai_partner/logic/services/ml/translation_service.dart';

class TranslationCubit extends Cubit<TranslationState> {
  final TranslationService _service = TranslationService();

  // Initialize the Identifier directly here
  final _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);

  TranslationCubit() : super(TranslationInitial());

  /// 1. NEW: Detect Language from Scanned Text
  /// Call this when the user arrives from the Scanner screen
  Future<void> detectAndSetScannedText(String text) async {
    if (text.trim().isEmpty) return;

    emit(TranslationDetecting());

    try {
      final String languageCode = await _languageIdentifier.identifyLanguage(
        text,
      );

      // 'und' means undetermined, we can default to 'en' or leave it to the user
      final finalCode = languageCode == 'und' ? 'en' : languageCode;

      emit(TranslationDetected(finalCode, text));
    } catch (e) {
      emit(TranslationError("Could not identify language: ${e.toString()}"));
    }
  }

  /// 2. Core Translation Method
  Future<void> translateText({
    required String text,
    required TranslateLanguage source,
    required TranslateLanguage target,
  }) async {
    if (text.trim().isEmpty) return;

    try {
      // Check if model needs downloading
      final isDownloaded = await _service.isLanguageDownloaded(target);

      if (!isDownloaded) {
        emit(TranslationLoading("Downloading ${target.name} pack..."));
      } else {
        emit(TranslationLoading("Translating..."));
      }

      final result = await _service.translate(
        text: text,
        source: source,
        target: target,
      );

      // Match the updated Success state props
      emit(
        TranslationSuccess(
          translatedText: result,
          sourceLang: source.name,
          targetLang: target.name,
        ),
      );
    } catch (e) {
      emit(TranslationError("Failed to translate: ${e.toString()}"));
    }
  }

  void reset() => emit(TranslationInitial());

  @override
  Future<void> close() {
    _languageIdentifier.close(); // Important: cleanup resources
    return super.close();
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'translation_state.dart';
import 'package:ai_partner/logic/services/ml/translation_service.dart';

class TranslationCubit extends Cubit<TranslationState> {
  final TranslationService _service = TranslationService();
  final _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);

  TranslationCubit() : super(TranslationInitial());

  /// 1. Detect Language from Scanned Text
  Future<void> detectAndSetScannedText(
    String text, {
    required String errorMessage,
  }) async {
    if (text.trim().isEmpty) return;

    emit(TranslationDetecting());

    try {
      final String languageCode = await _languageIdentifier.identifyLanguage(
        text,
      );
      final finalCode = languageCode == 'und' ? 'en' : languageCode;

      emit(TranslationDetected(finalCode, text));
    } catch (e) {
      emit(TranslationError(errorMessage));
    }
  }

  /// 2. Core Translation Method
  Future<void> translateText({
    required String text,
    required TranslateLanguage source,
    required TranslateLanguage target,
    required String translatingMessage,
    required String downloadingMessage,
    required String errorMessage,
  }) async {
    if (text.trim().isEmpty) return;

    try {
      final isDownloaded = await _service.isLanguageDownloaded(target);

      // We emit the raw message or a specific state that the UI can format
      if (!isDownloaded) {
        emit(TranslationLoading("$downloadingMessage ${target.name}..."));
      } else {
        emit(TranslationLoading(translatingMessage));
      }

      final result = await _service.translate(
        text: text,
        source: source,
        target: target,
      );

      emit(
        TranslationSuccess(
          translatedText: result,
          sourceLang: source.name,
          targetLang: target.name,
        ),
      );
    } catch (e) {
      emit(TranslationError(errorMessage));
    }
  }

  void reset() => emit(TranslationInitial());

  @override
  Future<void> close() {
    _languageIdentifier.close();
    return super.close();
  }
}

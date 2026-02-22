import 'package:ai_partner/logic/translation/translation_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'translation_state.dart';

class TranslationCubit extends Cubit<TranslationState> {
  final TranslationService _service = TranslationService();

  TranslationCubit() : super(TranslationInitial());

  Future<void> translateText({
    required String text,
    required TranslateLanguage source,
    required TranslateLanguage target,
  }) async {
    if (text.trim().isEmpty) return;

    // 1. Check if model needs downloading
    final isDownloaded = await _service.isLanguageDownloaded(target);

    if (!isDownloaded) {
      emit(TranslationLoading("Downloading ${target.name} pack..."));
    } else {
      emit(TranslationLoading("Translating..."));
    }

    try {
      final result = await _service.translate(
        text: text,
        source: source,
        target: target,
      );
      emit(TranslationSuccess(result));
    } catch (e) {
      emit(TranslationError("Failed to translate: ${e.toString()}"));
    }
  }

  void reset() => emit(TranslationInitial());
}

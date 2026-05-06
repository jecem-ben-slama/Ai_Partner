import 'package:flutter_bloc/flutter_bloc.dart';
import 'translation_state.dart';

//* Service imports
import 'package:ai_partner/logic/services/haptic_service.dart';
import 'package:ai_partner/logic/services/notification_service.dart';
import 'package:ai_partner/logic/services/sound_service.dart';
import 'package:ai_partner/logic/services/ml/translation_service.dart';
import 'package:ai_partner/logic/services/ml/language_id_service.dart';

class TranslationCubit extends Cubit<TranslationState> {
  final LanguageIdService _languageService;
  final TranslationService _translationService;
  final HapticService _hapticService;
  final SoundService _soundService;
  final NotificationService _notificationService;

  TranslationCubit(
    this._languageService,
    this._translationService,
    this._hapticService,
    this._soundService,
    this._notificationService,
  ) : super(TranslationInitial());

  Future<void> detectAndSetScannedText(
    String text, {
    required String errorMessage,
  }) async {
    if (text.trim().isEmpty) return;

    emit(TranslationDetecting());
    await _hapticService.triggerLoading();

    try {
      final String finalCode = await _languageService.identifyLanguage(text);

      await _hapticService.trigger();
      emit(TranslationDetected(finalCode, text));

      await _notificationService.showNotification(
        id: 1,
        title: "Language Detected",
        body: "Source language identified as ${finalCode.toUpperCase()}.",
      );
      _soundService.playSuccess();
    } catch (e) {
      emit(TranslationError(errorMessage));
      _soundService.playError();
    }
  }

  Future<void> translateText({
    required String text,
    required String sourceCode, // Changed from TranslateLanguage
    required String targetCode, // Changed from TranslateLanguage
    required String translatingMessage,
    required String downloadingMessage,
    required String errorMessage,
  }) async {
    if (text.trim().isEmpty) return;

    try {
      final isDownloaded = await _translationService.isLanguageDownloaded(
        targetCode,
      );

      if (!isDownloaded) {
        await _hapticService.triggerLoading();
        emit(TranslationLoading("$downloadingMessage $targetCode..."));
      } else {
        emit(TranslationLoading(translatingMessage));
      }

      final result = await _translationService.translate(
        text: text,
        sourceCode: sourceCode,
        targetCode: targetCode,
      );

      await _notificationService.showNotification(
        id: 2,
        title: "Translation Ready",
        body: "Successfully translated to ${targetCode.toUpperCase()}.",
      );

      await _hapticService.triggerSuccess();
      _soundService.playSuccess();
      emit(
        TranslationSuccess(
          translatedText: result,
          sourceLang: sourceCode,
          targetLang: targetCode,
        ),
      );
    } catch (e) {
      await _hapticService.triggerError();
      _soundService.playError();
      emit(TranslationError(errorMessage));
    }
  }

  void reset() => emit(TranslationInitial());
}

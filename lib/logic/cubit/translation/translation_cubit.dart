import 'package:ai_partner/logic/services/haptic_service.dart';
import 'package:ai_partner/logic/services/notification_service.dart';
import 'package:ai_partner/logic/services/sound_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'translation_state.dart';
import 'package:ai_partner/logic/services/ml/translation_service.dart';

class TranslationCubit extends Cubit<TranslationState> {
  final _service = TranslationService();
  final HapticService _hapticService;
  final SoundService _soundService;
  final NotificationService _notificationService;

  final _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);

  TranslationCubit(
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
      final String languageCode = await _languageIdentifier.identifyLanguage(
        text,
      );
      final finalCode = languageCode == 'und' ? 'en' : languageCode;

      await _hapticService.trigger();
      emit(TranslationDetected(finalCode, text));

      await _notificationService.showNotification(
        id: 1,
        title: "Language Detected",
        body: "Source language identified as ${finalCode.toUpperCase()}.",
      );
      _soundService.playSuccess();
    } catch (e) {
      // ✅ Error Notification
      await _notificationService.showNotification(
        id: 101,
        title: "Detection Failed",
        body: errorMessage,
      );
      await _hapticService.triggerError();
      emit(TranslationError(errorMessage));
      _soundService.playError();
    }
  }

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

      if (!isDownloaded) {
        await _hapticService.triggerLoading();
        emit(TranslationLoading("$downloadingMessage ${target.name}..."));
      } else {
        emit(TranslationLoading(translatingMessage));
      }

      final result = await _service.translate(
        text: text,
        source: source,
        target: target,
      );

      await _notificationService.showNotification(
        id: 2,
        title: "Translation Ready",
        body: "Successfully translated to ${target.name}.",
      );

      await _hapticService.triggerSuccess();
      _soundService.playSuccess();
      emit(
        TranslationSuccess(
          translatedText: result,
          sourceLang: source.name,
          targetLang: target.name,
        ),
      );
    } catch (e) {
      // ✅ Error Notification
      await _notificationService.showNotification(
        id: 102,
        title: "Translation Error",
        body: "Could not complete translation. Please check your connection.",
      );
      await _hapticService.triggerError();
      _soundService.playError();
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

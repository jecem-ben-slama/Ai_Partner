import 'package:flutter_bloc/flutter_bloc.dart';
import 'tts_state.dart';

//* Service imports
import 'package:ai_partner/logic/services/haptic_service.dart';
import 'package:ai_partner/logic/services/sound_service.dart';
import 'package:ai_partner/logic/services/tts_service.dart';
import 'package:ai_partner/logic/services/ml/language_id_service.dart'; // Added

class TtsCubit extends Cubit<TtsState> {
  final TtsService _service;
  final HapticService _hapticService;
  final SoundService _soundService;
  final LanguageIdService _languageService; // Added

  TtsCubit(
    this._service,
    this._hapticService,
    this._soundService,
    this._languageService, // Injected
  ) : super(const TtsState()) {
    // Setup handlers once when the Cubit is created
    _service.setHandlers(
      onStart: () {
        _hapticService.trigger();
        emit(state.copyWith(status: TtsStatus.playing));
      },
      onComplete: () {
        emit(state.copyWith(status: TtsStatus.stopped, start: 0, end: 0));
      },
      onCancel: () {
        emit(state.copyWith(status: TtsStatus.stopped, start: 0, end: 0));
      },
      onProgress: (start, end) {
        emit(state.copyWith(start: start, end: end));
      },
      onError: (err) {
        _hapticService.triggerError();
        _soundService.playError();
        emit(state.copyWith(status: TtsStatus.error, errorMessage: err));
      },
    );
  }

  Future<void> detectAndSpeak(
    String text, {
    String? defaultErrorMessage,
  }) async {
    if (text.trim().isEmpty) {
      await _hapticService.triggerError();
      _soundService.playError();
      return;
    }

    emit(state.copyWith(status: TtsStatus.loading, errorMessage: ''));
    await _hapticService.triggerLoading();

    try {
      // 1. Identify the language code using the injected service
      final String languageCode = await _languageService.identifyLanguage(text);

      // 2. Map the code to a user-friendly name
      final Map<String, String> langMap = {
        'en': 'English',
        'fr': 'French',
        'ar': 'Arabic',
        'es': 'Spanish',
        'de': 'German',
        'it': 'Italian',
      };

      // Since identifyLanguage now handles 'und' internally, we just check the output
      final String readableName =
          langMap[languageCode] ?? languageCode.toUpperCase();

      // 3. Update state with the language name
      emit(state.copyWith(detectedLanguage: readableName));

      // 4. Configure engine and speak
      await _service.setLanguage(languageCode);
      await _service.speak(text);
    } catch (e) {
      await _hapticService.triggerError();
      _soundService.playError();

      emit(
        state.copyWith(
          status: TtsStatus.error,
          errorMessage:
              defaultErrorMessage ?? "Could not play audio. Please try again.",
        ),
      );
    }
  }

  Future<void> stop() async {
    await _service.stop();
    await _hapticService.trigger();
    emit(state.copyWith(status: TtsStatus.stopped, detectedLanguage: ''));
  }

  Future<void> updateSpeed(double speed) async {
    await _service.setSpeed(speed);
    await _hapticService.trigger();
    emit(state.copyWith(speed: speed));
  }

  @override
  Future<void> close() async {
    await _service.stop();
    // Note: _languageService is managed at the Repository level,
    // so we don't need to close it here anymore.
    return super.close();
  }
}

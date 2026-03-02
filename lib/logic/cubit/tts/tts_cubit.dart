import 'package:ai_partner/logic/services/haptic_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'tts_state.dart';
import '../../services/tts_service.dart';

class TtsCubit extends Cubit<TtsState> {
  final TtsService _service;
  final HapticService _hapticService;
  final _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);

  TtsCubit(this._service, this._hapticService) : super(const TtsState()) {
    // Setup handlers once when the Cubit is created
    _service.setHandlers(
      onStart: () {
        // Subtle haptic feedback when speech actually begins
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
        // Heavy haptic feedback for engine-level errors
        _hapticService.triggerError();
        emit(state.copyWith(status: TtsStatus.error, errorMessage: err));
      },
    );
  }

  Future<void> detectAndSpeak(
    String text, {
    String? defaultErrorMessage,
  }) async {
    if (text.trim().isEmpty) {
      // Alert the user that input is missing
      await _hapticService.triggerError();
      return;
    }

    // 1. Enter Loading state
    emit(state.copyWith(status: TtsStatus.loading, errorMessage: ''));

    // 2. Start "Thinking" pulse while identifying language
    await _hapticService.triggerLoading();

    try {
      // 3. Identify the language code
      final String languageCode = await _languageIdentifier.identifyLanguage(
        text,
      );

      // 4. Map the code to a user-friendly name
      final Map<String, String> langMap = {
        'en': 'English',
        'fr': 'French',
        'ar': 'Arabic',
        'es': 'Spanish',
        'de': 'German',
        'it': 'Italian',
      };

      final String readableName = languageCode == 'und'
          ? 'Unknown'
          : (langMap[languageCode] ?? languageCode.toUpperCase());

      // 5. Update state with the language name
      emit(state.copyWith(detectedLanguage: readableName));

      // 6. Configure engine and speak
      if (languageCode != 'und') {
        await _service.setLanguage(languageCode);
      }

      // Voice starts playing; 'onStart' handler will trigger the success haptic
      await _service.speak(text);
    } catch (e) {
      // 7. Emit error message and trigger heavy vibration
      await _hapticService.triggerError();
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
    // Confirm the action was successful
    await _hapticService.trigger();
    emit(state.copyWith(status: TtsStatus.stopped, detectedLanguage: ''));
  }

  Future<void> updateSpeed(double speed) async {
    await _service.setSpeed(speed);
    // Tiny haptic "tick" when adjusting sliders
    await _hapticService.trigger();
    emit(state.copyWith(speed: speed));
  }

  @override
  Future<void> close() async {
    await _service.stop();
    await _languageIdentifier.close();
    return super.close();
  }
}

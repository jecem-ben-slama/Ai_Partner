import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'tts_state.dart';
import '../../services/tts_service.dart';

class TtsCubit extends Cubit<TtsState> {
  final TtsService _service;

  // Initialize ML Kit Language Identifier
  final _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);

  TtsCubit(this._service) : super(const TtsState()) {
    // Setup handlers once when the Cubit is created
    _service.setHandlers(
      onStart: () => emit(state.copyWith(status: TtsStatus.playing)),
      onComplete: () =>
          emit(state.copyWith(status: TtsStatus.stopped, start: 0, end: 0)),
      onCancel: () =>
          emit(state.copyWith(status: TtsStatus.stopped, start: 0, end: 0)),
      onProgress: (start, end) => emit(state.copyWith(start: start, end: end)),
      onError: (err) =>
          emit(state.copyWith(status: TtsStatus.error, errorMessage: err)),
    );
  }

  /// The main method called by your UI "Play" button
  Future<void> detectAndSpeak(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Enter Loading state to trigger UI spinner/disable buttons
    emit(state.copyWith(status: TtsStatus.loading, errorMessage: ''));

    try {
      // 2. Identify the language code (e.g., 'en', 'fr', 'ar')
      final String languageCode = await _languageIdentifier.identifyLanguage(
        text,
      );

      // 3. Map the code to a user-friendly name
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

      // 4. Update state with the language name
      emit(state.copyWith(detectedLanguage: readableName));

      // 5. Configure engine and speak
      if (languageCode != 'und') {
        await _service.setLanguage(languageCode);
      }

      await _service.speak(text);
      // Note: status changes to .playing via the onStart handler in the constructor
    } catch (e) {
      emit(
        state.copyWith(
          status: TtsStatus.error,
          errorMessage: "Failed to process text: ${e.toString()}",
        ),
      );
    }
  }

  Future<void> stop() async {
    await _service.stop();
    emit(state.copyWith(status: TtsStatus.stopped, detectedLanguage: ''));
  }

  Future<void> updateSpeed(double speed) async {
    await _service.setSpeed(speed);
    emit(state.copyWith(speed: speed));
  }

  // inside TtsCubit
  @override
  Future<void> close() async {
    await _service.stop(); // Stop audio immediately
    await _languageIdentifier.close(); // Close ML Kit
    return super.close();
  }
}

import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();

  TtsService() {
    _initTts();
  }

  /// Initial configuration for the TTS engine
  void _initTts() async {
    // 1. Basic defaults
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    // 2. Android Specifics
    if (Platform.isAndroid) {
      // QueueMode 0 (or '0') ensures a new 'speak' call interrupts the previous one.
      // This prevents "overlapping voices" if the user clicks play twice.
      await _tts.setQueueMode(0);
    }

    // 3. iOS Specifics
    if (Platform.isIOS) {
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
      ]);
    }
  }

  /// Registers callbacks from the Cubit to handle UI updates
  void setHandlers({
    required Function() onStart,
    required Function() onComplete,
    required Function(int start, int end) onProgress,
    required Function(String err) onError,
    required Function() onCancel,
  }) {
    _tts.setStartHandler(() {
      onStart();
    });

    _tts.setCompletionHandler(() {
      onComplete();
    });

    _tts.setCancelHandler(() {
      onCancel();
    });

    // Handles the 'dynamic' type requirement for ErrorHandler
    _tts.setErrorHandler((dynamic msg) {
      onError(msg.toString());
    });

    // Captures the current word offsets for the highlighting effect
    _tts.setProgressHandler((String text, int start, int end, String word) {
      onProgress(start, end);
    });
  }

  /// Changes the voice language (e.g., 'fr', 'ar', 'en')
  Future<void> setLanguage(String langCode) async {
    await _tts.setLanguage(langCode);
  }

  /// Adjusts the reading speed (usually between 0.0 and 1.0)
  Future<void> setSpeed(double speed) async {
    await _tts.setSpeechRate(speed);
  }

  /// Core playback commands
  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await _tts.speak(text);
    }
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  Future<void> pause() async {
    await _tts.pause();
  }

  /// Call this when the app is shut down to release native resources
  Future<void> dispose() async {
    await _tts.stop();
  }
}

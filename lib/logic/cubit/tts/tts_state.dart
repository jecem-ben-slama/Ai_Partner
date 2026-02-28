enum TtsStatus { initial, loading, playing, stopped, error }
class TtsState {
  final TtsStatus status;
  final String errorMessage;

  // Highlight indices: 'start' is the beginning of the current word,
  // 'end' is the end of the current word in the text string.
  final int start;
  final int end;

  final double speed;

  // The readable name of the language identified by ML Kit (e.g., "French")
  final String detectedLanguage;

  const TtsState({
    this.status = TtsStatus.initial,
    this.errorMessage = '',
    this.start = 0,
    this.end = 0,
    this.speed = 0.5,
    this.detectedLanguage = '',
  });

  // Use copyWith to update state without losing other values
  TtsState copyWith({
    TtsStatus? status,
    String? errorMessage,
    int? start,
    int? end,
    double? speed,
    String? detectedLanguage,
  }) {
    return TtsState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      start: start ?? this.start,
      end: end ?? this.end,
      speed: speed ?? this.speed,
      detectedLanguage: detectedLanguage ?? this.detectedLanguage,
    );
  }
}

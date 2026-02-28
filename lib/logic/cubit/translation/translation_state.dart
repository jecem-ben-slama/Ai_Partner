import 'package:equatable/equatable.dart';

abstract class TranslationState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// 1. Initial State
class TranslationInitial extends TranslationState {}

/// 2. Detection State (New)
/// Use this when ML Kit is identifying the language of the scanned text.
class TranslationDetecting extends TranslationState {}

/// 3. Detection Success (New)
/// Use this once the language is identified but before translation starts.
class TranslationDetected extends TranslationState {
  final String detectedLangCode;
  final String originalText;

  TranslationDetected(this.detectedLangCode, this.originalText);

  @override
  List<Object?> get props => [detectedLangCode, originalText];
}

/// 4. Loading State
/// message can be "Downloading models..." or "Translating..."
class TranslationLoading extends TranslationState {
  final String message;
  TranslationLoading(this.message);

  @override
  List<Object?> get props => [message];
}

/// 5. Success State
class TranslationSuccess extends TranslationState {
  final String translatedText;
  final String sourceLang;
  final String targetLang;

  TranslationSuccess({
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
  });

  @override
  List<Object?> get props => [translatedText, sourceLang, targetLang];
}

/// 6. Error State
class TranslationError extends TranslationState {
  final String error;
  TranslationError(this.error);

  @override
  List<Object?> get props => [error];
}

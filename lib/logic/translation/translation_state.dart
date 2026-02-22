import 'package:equatable/equatable.dart';

abstract class TranslationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TranslationInitial extends TranslationState {}

class TranslationLoading extends TranslationState {
  final String
  message; // e.g., "Downloading language pack..." or "Translating..."
  TranslationLoading(this.message);

  @override
  List<Object?> get props => [message];
}

class TranslationSuccess extends TranslationState {
  final String translatedText;
  TranslationSuccess(this.translatedText);

  @override
  List<Object?> get props => [translatedText];
}

class TranslationError extends TranslationState {
  final String error;
  TranslationError(this.error);

  @override
  List<Object?> get props => [error];
}

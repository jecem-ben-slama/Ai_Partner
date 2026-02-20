abstract class TextState {}

class TextInitial extends TextState {}

class TextLoading extends TextState {}

class TextSuccess extends TextState {
  final String text;
  TextSuccess(this.text);
}

class TextError extends TextState {
  final String error;
  TextError(this.error);
}

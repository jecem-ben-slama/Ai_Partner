import 'package:ai_partner/data/models/barcode_model.dart';

abstract class TextState {}

class TextInitial extends TextState {}

class TextLoading extends TextState {}

class TextSuccess extends TextState {
  final String? recognizedText;
  final List<BarcodeModel> barcodes; // Using the model we created

  TextSuccess({this.recognizedText, this.barcodes = const []});
}

class TextError extends TextState {
  final String message;
  TextError(this.message);
}

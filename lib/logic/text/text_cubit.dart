import 'dart:io';
import 'package:ai_partner/logic/ml/text_recognaizer_service.dart';
import 'package:ai_partner/logic/text/text_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TextCubit extends Cubit<TextState> {
  final TextRecognizerService _service;
  TextCubit(this._service) : super(TextInitial());

  Future<void> recognizeText(File image) async {
    emit(TextLoading());
    try {
      final result = await _service.processImage(image);
      emit(TextSuccess(result));
    } catch (e) {
      emit(TextError("Failed to scan text: $e"));
    }
  }
}

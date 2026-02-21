import 'dart:io';

import 'package:ai_partner/logic/ml/text_recognaizer_service.dart';
import 'package:ai_partner/logic/text/text_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TextCubit extends Cubit<TextState> {
  // Use the universal service we discussed
  final UniversalScannerService _service;

  TextCubit(this._service) : super(TextInitial());

  Future<void> scanImage(File image) async {
    emit(TextLoading());
    try {
      // The service now returns a Map or a custom Result object
      final results = await _service.processImage(image);

      emit(
        TextSuccess(
          recognizedText: results['text'],
          barcodes: (results['barcode'] != null)
              ? [results['barcode']] // Wrapping the single result in a list
              : [],
        ),
      );
    } catch (e) {
      emit(TextError("Universal scan failed: $e"));
    }
  }
}

import 'dart:io';
import 'package:ai_partner/models/scan_result_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/barcode_model.dart';
import '../../services/universal_scanner_service.dart';
import 'vision_state.dart';

class VisionCubit extends Cubit<VisionState> {
  final UniversalScannerService _scannerService;

  VisionCubit(this._scannerService) : super(VisionInitial());

  Future<void> scanImage(File imageFile) async {
    emit(VisionLoading());

    try {
      // The Universal Service runs Text and Barcode scans in parallel
      final results = await _scannerService.processUniversal(imageFile);

      // Separate the results back into text and barcodes for the state
      String? recognizedText;
      List<BarcodeModel> foundBarcodes = [];

      for (var result in results) {
        if (result.type == ScanDataType.text) {
          recognizedText = result.content;
        } else {
          foundBarcodes.add(
            BarcodeModel(
              value: result.content,
              type: result.label ?? "QR_CODE",
            ),
          );
        }
      }

      emit(VisionSuccess(fullText: recognizedText, barcodes: foundBarcodes));
    } catch (e) {
      emit(VisionError("AI failed to process image: ${e.toString()}"));
    }
  }

  // Reset the scanner for a new photo
  void reset() => emit(VisionInitial());
}

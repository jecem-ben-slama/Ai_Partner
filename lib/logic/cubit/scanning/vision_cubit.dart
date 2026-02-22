import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_partner/models/scan_result_model.dart';
import '../../services/universal_scanner_service.dart';
import 'vision_state.dart';

class VisionCubit extends Cubit<VisionState> {
  final UniversalScannerService _scannerService;

  VisionCubit(this._scannerService) : super(VisionInitial());

  Future<void> scanImage(File imageFile) async {
    emit(VisionLoading());

    try {
      // The service now handles all the mapping to VisionResult
      final List<VisionResult> results = await _scannerService.processUniversal(
        imageFile,
      );

      if (results.isEmpty) {
        emit(
           VisionError(
            "No text or barcodes detected. Try a clearer photo.",
          ),
        );
      } else {
        // Emit the unified results list to the UI
        emit(VisionSuccess(results: results));
      }
    } catch (e) {
      emit(VisionError("AI failed to process image: ${e.toString()}"));
    }
  }

  // Reset for a new scan session
  void reset() => emit(VisionInitial());
}

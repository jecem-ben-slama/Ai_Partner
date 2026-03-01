import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_partner/models/scan_result_model.dart';
import '../../services/universal_scanner_service.dart';
import 'vision_state.dart';

class VisionCubit extends Cubit<VisionState> {
  final UniversalScannerService _scannerService;

  VisionCubit(this._scannerService) : super(VisionInitial());

  // Add parameters for the messages
  Future<void> scanImage({
    required File imageFile,
    required String emptyMessage,
    required String errorMessage,
  }) async {
    emit(VisionLoading());

    try {
      final List<VisionResult> results = await _scannerService.processUniversal(
        imageFile,
      );

      if (results.isEmpty) {
        emit(VisionError(emptyMessage));
      } else {
        emit(VisionSuccess(results: results));
      }
    } catch (e) {
      emit(VisionError("$errorMessage ${e.toString()}"));
    }
  }

  void reset() => emit(VisionInitial());
}

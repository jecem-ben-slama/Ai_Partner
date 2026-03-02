import 'dart:io';
import 'package:ai_partner/logic/services/haptic_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_partner/models/scan_result_model.dart';
import '../../services/universal_scanner_service.dart';
import 'vision_state.dart';

class VisionCubit extends Cubit<VisionState> {
  final UniversalScannerService _scannerService;
  final HapticService _hapticService;

  VisionCubit(this._scannerService, this._hapticService)
    : super(VisionInitial());

  // Add parameters for the messages
  Future<void> scanImage({
    required File imageFile,
    required String emptyMessage,
    required String errorMessage,
  }) async {
    emit(VisionLoading());
    _hapticService.triggerLoading();

    try {
      final List<VisionResult> results = await _scannerService.processUniversal(
        imageFile,
      );

      if (results.isEmpty) {
        _hapticService.triggerError();
        emit(VisionError(emptyMessage));
      } else {
        _hapticService.triggerSuccess();
        emit(VisionSuccess(results: results));
      }
    } catch (e) {
      _hapticService.triggerError();
      emit(VisionError("$errorMessage ${e.toString()}"));
    }
  }

  void reset() => emit(VisionInitial());
}

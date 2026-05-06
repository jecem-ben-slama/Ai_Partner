import 'dart:io';
import 'package:ai_partner/logic/services/haptic_service.dart';
import 'package:ai_partner/logic/services/sound_service.dart';
import 'package:ai_partner/logic/services/notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_partner/models/scan_result_model.dart';
import '../../services/universal_scanner_service.dart';
import 'vision_state.dart';

class VisionCubit extends Cubit<VisionState> {
  final UniversalScannerService _scannerService;
  final HapticService _hapticService;
  final SoundService _soundService;
  final NotificationService _notificationService;

  VisionCubit(
    this._scannerService,
    this._hapticService,
    this._soundService,
    this._notificationService,
  ) : super(VisionInitial());

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
        // ✅ Notification for empty results
        await _notificationService.showNotification(
          id: 103,
          title: "No Results",
          body: emptyMessage,
        );
        _soundService.playError();
        _hapticService.triggerError();
        emit(VisionError(emptyMessage));
      } else {
        await _notificationService.showNotification(
          id: 3,
          title: "Scan Successful",
          body: "Identified ${results.length} items.",
        );
        _soundService.playSuccess();
        _hapticService.triggerSuccess();
        emit(VisionSuccess(results: results));
      }
    } catch (e) {
      // ✅ Notification for system errors
      await _notificationService.showNotification(
        id: 104,
        title: "Scan Failed",
        body: "An error occurred while processing the image.",
      );
      _soundService.playError();
      _hapticService.triggerError();
      emit(VisionError("$errorMessage ${e.toString()}"));
    }
  }

  void reset() => emit(VisionInitial());
}

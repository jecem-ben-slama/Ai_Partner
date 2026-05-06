import 'package:ai_partner/logic/repo/scan_repository.dart';
import 'package:ai_partner/logic/services/haptic_service.dart';
import 'package:ai_partner/logic/services/notification_service.dart';
import 'package:ai_partner/logic/services/sound_service.dart';
import 'package:ai_partner/models/scan_result_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'saved_scan_state.dart';

class SavedScanCubit extends Cubit<SavedScanState> {
  final ScanRepository _scanRepository;
  final SoundService _soundService;
  final HapticService _hapticService;
  final NotificationService _notificationService;

  SavedScanCubit(
    this._scanRepository,
    this._hapticService,
    this._soundService,
    this._notificationService,
  ) : super(SavedScanInitial());

  Future<void> loadHistory({String? errorMessage}) async {
    emit(SavedScanLoading());
    try {
      final scans = await _scanRepository.getScans();
      emit(SavedScanLoaded(scans));
    } catch (e) {
      _hapticService.triggerError();
      _soundService.playError();
      emit(SavedScanError(errorMessage ?? "Could not load history."));
    }
  }

  Future<void> saveNewScan(
    List<VisionResult> results, {
    required String errorMessage,
  }) async {
    try {
      if (results.isNotEmpty) {
        await _scanRepository.insertScan(results.first);

        await _notificationService.showNotification(
          id: 4,
          title: "Scan Saved",
          body: "Successfully added to your offline history.",
        );

        _soundService.playSuccess();
        _hapticService.triggerSuccess();
      }

      await loadHistory();
    } catch (e) {
      await _notificationService.showNotification(
        id: 104,
        title: "Save Error",
        body: "Failed to save the scan locally.",
      );
      _hapticService.triggerError();
      _soundService.playError();
      emit(SavedScanError(errorMessage));
    }
  }

  void toggleFavorite(String id) async {
    if (state is SavedScanLoaded) {
      try {
        final currentScans = (state as SavedScanLoaded).savedScans;
        final scan = currentScans.firstWhere((s) => s.id == id);

        final newStatus = !scan.isFavorite;
        await _scanRepository.toggleFavorite(id, newStatus);

        _hapticService.triggerSuccess();
        _soundService.playSuccess();

        await loadHistory();
      } catch (e) {
        _hapticService.triggerError();
      }
    }
  }

  void updateLabel(String id, String newLabel) async {
    if (state is SavedScanLoaded) {
      try {
        await _scanRepository.updateScanTitle(id, newLabel);

        _hapticService.trigger();
        _soundService.playSuccess();

        await loadHistory();
      } catch (e) {
        _hapticService.triggerError();
      }
    }
  }

  Future<void> deleteItem(String id, {String? errorMessage}) async {
    try {
      await _scanRepository.deleteScan(id);

      // Feedback for success
      _hapticService.triggerSuccess();
      _soundService.playSuccess();

      await _notificationService.showNotification(
        id: 5,
        title: "Deleted",
        body: "Item removed from history.",
      );

      await loadHistory();
    } catch (e) {
      // Feedback for error
      _hapticService.triggerError();
      _soundService.playError();

      await _notificationService.showNotification(
        id: 105,
        title: "Delete Failed",
        body: "Could not remove the item from the database.",
      );

      emit(SavedScanError(errorMessage ?? "Error deleting item"));
    }
  }

  Future<void> clearAll({String? errorMessage}) async {
    try {
      await _scanRepository.deleteAll();

      _hapticService.triggerSuccess();
      _soundService.playSuccess();

      await _notificationService.showNotification(
        id: 6,
        title: "History Cleared",
        body: "All saved scans have been deleted.",
      );

      emit(SavedScanLoaded(const []));
    } catch (e) {
      _hapticService.triggerError();
      _soundService.playError();

      await _notificationService.showNotification(
        id: 106,
        title: "Error",
        body: "Failed to clear the local database.",
      );
      emit(SavedScanError(errorMessage ?? "Error clearing history"));
    }
  }

  /// Use this for your Settings Page reset logic
  void clearAllLocalData() {
    emit(SavedScanLoaded(const []));
  }
}

import 'package:ai_partner/logic/services/haptic_service.dart';
import 'package:ai_partner/logic/services/sound_service.dart';
import 'package:ai_partner/logic/services/storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_partner/models/scan_result_model.dart';
import 'saved_scan_state.dart';

class SavedScanCubit extends Cubit<SavedScanState> {
  final StorageService _storageService;
  final SoundService _soundService;
  final HapticService _hapticService;

  SavedScanCubit(this._storageService, this._hapticService, this._soundService)
    : super(SavedScanInitial());

  Future<void> loadHistory({String? errorMessage}) async {
    emit(SavedScanLoading());
    try {
      final scans = await _storageService.getHistory();
      _hapticService.trigger();
      _soundService.playSuccess();
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
      final resultsJson = results.map((res) => res.toJson()).toList();
      await _storageService.saveScan(resultsJson);
      await loadHistory();
    } catch (e) {
       _hapticService.triggerError();
      _soundService.playError();
      emit(SavedScanError(errorMessage));
      
    }
  }

  void toggleFavorite(String id) async {
    if (state is SavedScanLoaded) {
      final List<Map<String, dynamic>> currentHistory = List.from(
        (state as SavedScanLoaded).savedScans,
      );

      for (var entry in currentHistory) {
        if (entry['id'] == id) {
          final results = entry['results'] as List;
          if (results.isNotEmpty) {
            results[0]['isFavorite'] = !(results[0]['isFavorite'] ?? false);
          }
        }
      }

      await _storageService.saveFullHistory(currentHistory);
       _hapticService.triggerSuccess();
      _soundService.playSuccess();
      emit(SavedScanLoaded(currentHistory));
    }
  }

  void updateLabel(String id, String newLabel) async {
    if (state is SavedScanLoaded) {
      await _storageService.updateScanLabel(id, newLabel);
      final updatedHistory = await _storageService.getHistory();
       _hapticService.trigger();
      _soundService.playSuccess();
      emit(SavedScanLoaded(updatedHistory));
    }
  }

  Future<void> deleteItem(String id, {required String errorMessage}) async {
    try {
      await _storageService.deleteScanById(id);
      await loadHistory();
    } catch (e) {
       _hapticService.triggerError();
      _soundService.playError();
      emit(SavedScanError(errorMessage));
    }
  }

  Future<void> clearAll({required String errorMessage}) async {
    try {
      await _storageService.deleteAll();
      emit(SavedScanLoaded(const []));
    } catch (e) {
      emit(SavedScanError(errorMessage));
       _hapticService.triggerError();
      _soundService.playError();
    }
  }
}

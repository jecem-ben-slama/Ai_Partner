import 'package:ai_partner/logic/services/storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_partner/models/scan_result_model.dart';
import 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final StorageService _storageService;

  HistoryCubit(this._storageService) : super(HistoryInitial());

  Future<void> loadHistory({String? errorMessage}) async {
    emit(HistoryLoading());
    try {
      final scans = await _storageService.getHistory();
      emit(HistoryLoaded(scans));
    } catch (e) {
      emit(HistoryError(errorMessage ?? "Could not load history."));
    }
  }

  Future<void> saveNewScan(
    List<VisionResult> results, {
    required String errorMessage,
  }) async {
    try {
      final resultsJson = results.map((res) => res.toJson()).toList();
      await _storageService.saveScan(resultsJson);
      // We pass null here because loadHistory has its own default or we can pass a specific message
      await loadHistory();
    } catch (e) {
      emit(HistoryError(errorMessage));
    }
  }

  void toggleFavorite(String id) async {
    if (state is HistoryLoaded) {
      final List<Map<String, dynamic>> currentHistory = List.from(
        (state as HistoryLoaded).savedScans,
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
      emit(HistoryLoaded(currentHistory));
    }
  }

  void updateLabel(String id, String newLabel) async {
    if (state is HistoryLoaded) {
      await _storageService.updateScanLabel(id, newLabel);
      final updatedHistory = await _storageService.getHistory();
      emit(HistoryLoaded(updatedHistory));
    }
  }

  Future<void> deleteItem(String id, {required String errorMessage}) async {
    try {
      await _storageService.deleteScanById(id);
      await loadHistory();
    } catch (e) {
      emit(HistoryError(errorMessage));
    }
  }

  Future<void> clearAll({required String errorMessage}) async {
    try {
      await _storageService.deleteAll();
      emit(HistoryLoaded(const []));
    } catch (e) {
      emit(HistoryError(errorMessage));
    }
  }
}

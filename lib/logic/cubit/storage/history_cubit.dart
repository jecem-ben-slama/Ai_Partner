
import 'package:ai_partner/logic/services/storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_partner/models/scan_result_model.dart';
import 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final StorageService _storageService;

  HistoryCubit(this._storageService) : super(HistoryInitial());

  Future<void> loadHistory() async {
    emit(HistoryLoading());
    try {
      final scans = await _storageService.getHistory();
      emit(HistoryLoaded(scans));
    } catch (e) {
      emit(HistoryError("Could not load history."));
    }
  }

  Future<void> saveNewScan(List<VisionResult> results) async {
    try {
      final resultsJson = results.map((res) => res.toJson()).toList();
      await _storageService.saveScan(resultsJson);
      await loadHistory(); 
    } catch (e) {
      emit(HistoryError("Failed to save."));
    }
  }
// Inside history_cubit.dart
  void toggleFavorite(String id) async {
    if (state is HistoryLoaded) {
      final List<Map<String, dynamic>> currentHistory = List.from(
        (state as HistoryLoaded).savedScans,
      );

      for (var entry in currentHistory) {
        if (entry['id'] == id) {
          // Toggle the favorite status of the first result
          final results = entry['results'] as List;
          if (results.isNotEmpty) {
            results[0]['isFavorite'] = !(results[0]['isFavorite'] ?? false);
          }
        }
      }

      // Save to SharedPreferences via your StorageService
      await _storageService.saveFullHistory(currentHistory);
      emit(HistoryLoaded(currentHistory));
    }
  }
  Future<void> deleteItem(String id) async {
    try {
      await _storageService.deleteScanById(id);
      await loadHistory();
    } catch (e) {
      emit(HistoryError("Delete failed."));
    }
  }
  // Clear the whole history
  Future<void> clearAll() async {
    try {
      await _storageService.deleteAll();
      emit(HistoryLoaded(const []));
    } catch (e) {
      emit(HistoryError("Failed to clear history."));
    }
  }
}

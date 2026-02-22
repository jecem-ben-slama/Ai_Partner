import 'package:ai_partner/logic/services/storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/barcode_model.dart';
import 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final StorageService _storageService;

  HistoryCubit(this._storageService) : super(HistoryInitial());

  // Load all saved scans from Shared Preferences
  Future<void> loadHistory() async {
    emit(HistoryLoading());
    try {
      final scans = await _storageService.getHistory();
      emit(HistoryLoaded(scans));
    } catch (e) {
      emit(HistoryError("Could not load memory."));
    }
  }

  // Save a new scan and refresh the list
  Future<void> saveNewScan(String? text, List<BarcodeModel> barcodes) async {
    try {
      await _storageService.saveScan(text, barcodes);
      await loadHistory(); // Refresh the state
    } catch (e) {
      emit(HistoryError("Failed to save scan."));
    }
  }

  // Delete a single item
  Future<void> deleteItem(String id) async {
    try {
      await _storageService.deleteScanById(id);
      await loadHistory(); // Refresh the UI list
    } catch (e) {
      emit(HistoryError("Could not delete item."));
    }
  }

  // Clear the whole history
  Future<void> clearAll() async {
    try {
      await _storageService.deleteAll();
      emit(HistoryLoaded(const [])); // Emit empty state directly
    } catch (e) {
      emit(HistoryError("Failed to clear history."));
    }
  }
}

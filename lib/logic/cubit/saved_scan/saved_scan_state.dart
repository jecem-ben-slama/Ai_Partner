import 'package:ai_partner/models/scan_result_model.dart';

abstract class SavedScanState {}

class SavedScanInitial extends SavedScanState {}

class SavedScanLoading extends SavedScanState {}

class SavedScanLoaded extends SavedScanState {
  // Now using the typed VisionResult model instead of generic Maps
  final List<VisionResult> savedScans;

  SavedScanLoaded(this.savedScans);
}

class SavedScanError extends SavedScanState {
  final String message;

  SavedScanError(this.message);
}

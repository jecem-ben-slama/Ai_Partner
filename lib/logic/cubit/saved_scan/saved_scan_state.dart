abstract class SavedScanState {}

class SavedScanInitial extends SavedScanState {}

class SavedScanLoading extends SavedScanState {}

class SavedScanLoaded extends SavedScanState {
  final List<Map<String, dynamic>> savedScans;
  SavedScanLoaded(this.savedScans);
}

class SavedScanError extends SavedScanState {
  final String message;
  SavedScanError(this.message);
}

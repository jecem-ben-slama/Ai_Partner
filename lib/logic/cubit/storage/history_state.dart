
abstract class HistoryState {}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<Map<String, dynamic>> savedScans;
  HistoryLoaded(this.savedScans);
}

class HistoryError extends HistoryState {
  final String message;
  HistoryError(this.message);
}

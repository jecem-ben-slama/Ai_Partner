import 'package:equatable/equatable.dart';
import 'package:ai_partner/models/scan_result_model.dart';

abstract class VisionState extends Equatable {
  const VisionState();

  @override
  List<Object?> get props => [];
}

class VisionInitial extends VisionState {}

class VisionLoading extends VisionState {}

class VisionSuccess extends VisionState {
  final List<VisionResult> results;

  const VisionSuccess({required this.results});

  @override
  List<Object?> get props => [results];
}

class VisionError extends VisionState {
  final String message;
  const VisionError(this.message);

  @override
  List<Object?> get props => [message];
}

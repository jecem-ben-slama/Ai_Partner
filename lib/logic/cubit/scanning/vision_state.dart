import 'package:ai_partner/models/barcode_model.dart';

abstract class VisionState {}

class VisionInitial extends VisionState {}

class VisionLoading extends VisionState {}

class VisionSuccess extends VisionState {
  // We keep them separate so the UI can prioritize showing QR actions at the top
  final String? fullText;
  final List<BarcodeModel> barcodes;

  // A helper to check if we found absolutely nothing
  bool get isEmpty =>
      (fullText == null || fullText!.isEmpty) && barcodes.isEmpty;

  VisionSuccess({this.fullText, this.barcodes = const []});
}

class VisionError extends VisionState {
  final String message;
  VisionError(this.message);
}

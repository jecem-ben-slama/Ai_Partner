import 'dart:io';
import 'package:ai_partner/logic/services/ml/barcode_scanner_service.dart';
import 'package:ai_partner/logic/services/ml/text_recognaizer_service.dart';
import 'package:ai_partner/models/scan_result_model.dart';

class UniversalScannerService {
  final _barcodeService = BarcodeScannerService();
  final _textService = TextRecognizerService();

  Future<List<VisionResult>> processUniversal(File file) async {
    // 1. Run both services in parallel
    // Both now return VisionResult-related data
    final results = await Future.wait([
      _barcodeService.scan(file), // returns List<VisionResult>
      _textService.scan(file), // returns VisionResult?
    ]);

    final List<VisionResult> unifiedResults = [];
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    // 2. Process Barcodes
    // results[0] is already a List<VisionResult>
    final List<VisionResult> rawBarcodes = results[0] as List<VisionResult>;

    for (int i = 0; i < rawBarcodes.length; i++) {
      final b = rawBarcodes[i];
      // Simply add them, updating the ID to be unique for this session
      unifiedResults.add(
        VisionResult(
          id: "${timestamp}_b$i",
          content: b.content, // Accessing .content instead of .value
          type: b.type,
          label: b.label,
        ),
      );
    }

    // 3. Process Text
    // results[1] is already a VisionResult?
    final VisionResult? textResult = results[1] as VisionResult?;

    if (textResult != null && textResult.content.trim().isNotEmpty) {
      unifiedResults.add(
        VisionResult(
          id: "${timestamp}_text",
          content: textResult.content,
          type: VisionType.text,
          label: "Detected Text",
        ),
      );
    }

    return unifiedResults;
  }

  void dispose() {
    _barcodeService.dispose();
    _textService.dispose();
  }
}

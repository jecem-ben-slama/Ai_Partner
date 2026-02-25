import 'dart:io';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:ai_partner/logic/services/ml/barcode_scanner_service.dart';
import 'package:ai_partner/logic/services/ml/text_recognaizer_service.dart';
import 'package:ai_partner/models/scan_result_model.dart';

class UniversalScannerService {
  final _barcodeService = BarcodeScannerService();
  final _textService = TextRecognizerService();

  Future<List<VisionResult>> processUniversal(File file) async {
    try {
      // 1. Run both services in parallel
      final results = await Future.wait([
        _barcodeService.scan(file),
        _textService.scan(file),
      ]);

      final List<VisionResult> unifiedResults = [];
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // 2. Process Barcodes
      final List<VisionResult> rawBarcodes = results[0] as List<VisionResult>;
      for (int i = 0; i < rawBarcodes.length; i++) {
        final b = rawBarcodes[i];
        unifiedResults.add(
          VisionResult(
            id: "${timestamp}_b$i",
            content: b.content,
            type: b.type,
            label: b.label,
          ),
        );
      }

      // 3. Process Text
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
    } catch (e) {
      debugPrint("Scan error: $e");
      rethrow;
    } finally {
      // --- THE STORAGE FIX ---
      // Delete the file immediately after ML Kit is done with it
      if (await file.exists()) {
        await file.delete();
        debugPrint("File deleted successfully to save storage.");
      }
    }
  }

  void dispose() {
    _barcodeService.dispose();
    _textService.dispose();
  }
}

import 'dart:io';
import 'package:ai_partner/data/models/scan_result_model.dart';
import 'package:ai_partner/logic/ml/barcode_scanner_service.dart';
import 'package:ai_partner/logic/ml/text_recognaizer_service.dart';

class UniversalScannerService {
  final _barcodeService = BarcodeScannerService();
  final _textService = TextRecognizerService();

  Future<List<SmartResult>> processUniversal(File file) async {
    // Run both services in parallel to save time
    final results = await Future.wait([
      _barcodeService.scan(file),
      _textService.scan(file),
    ]);

    final barcodes = results[0] as List<SmartResult>;
    final text = results[1] as SmartResult?;

    return [...barcodes, if (text != null) text];
  }

  void dispose() {
    _barcodeService.dispose();
    _textService.dispose();
  }
}

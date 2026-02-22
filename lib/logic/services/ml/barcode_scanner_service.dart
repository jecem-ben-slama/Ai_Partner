import 'dart:io';
import 'package:ai_partner/models/scan_result_model.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class BarcodeScannerService {
  final _scanner = BarcodeScanner();

  Future<List<SmartResult>> scan(File file) async {
    final inputImage = InputImage.fromFile(file);
    final barcodes = await _scanner.processImage(inputImage);

    return barcodes
        .map(
          (b) => SmartResult(
            content: b.displayValue ?? "Unknown Barcode",
            type: ScanDataType.barcode,
            label: b.type.name.toUpperCase(),
          ),
        )
        .toList();
  }

  void dispose() => _scanner.close();
}

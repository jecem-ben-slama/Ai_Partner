import 'dart:io';
import 'package:ai_partner/models/scan_result_model.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class BarcodeScannerService {
  //* instantiation du class provider par google ML kit
  final _scanner = BarcodeScanner();

  Future<List<VisionResult>> scan(File file) async {
    final inputImage = InputImage.fromFile(file);
    final barcodes = await _scanner.processImage(inputImage);

    return barcodes.map((barcode) {
      final String value = barcode.displayValue ?? "Unknown Barcode";

      // Corrected Type Mapping
      VisionType type;
      if (barcode.type == BarcodeType.url) {
        type = VisionType.url;
      } else if (barcode.type == BarcodeType.phone) {
        type = VisionType.phone;
      } else {
        type = VisionType.barcode;
      }

      return VisionResult(
        // Using a temp ID that can be unique enough for the list
        id: "bc_${barcode.hashCode}_${DateTime.now().microsecondsSinceEpoch}",
        content: value,
        type: type,
        label: barcode.format.name.toUpperCase(),
      );
    }).toList();
  }

  void dispose() => _scanner.close();
}

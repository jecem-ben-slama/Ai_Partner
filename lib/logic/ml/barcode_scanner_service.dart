import 'dart:io';
import 'package:ai_partner/data/models/barcode_model.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class BarcodeScannerService {
  // We enable all formats (QR, UPC, Code 128, etc.)
  final _barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.all]);

  Future<List<BarcodeModel>> scanImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);

    try {
      final List<Barcode> barcodes = await _barcodeScanner.processImage(
        inputImage,
      );

      // Convert ML Kit Barcodes to our custom BarcodeModel
      return barcodes.map((b) => BarcodeModel.fromMlKit(b)).toList();
    } catch (e) {
      return [];
    }
  }

  void dispose() {
    _barcodeScanner.close();
  }
}

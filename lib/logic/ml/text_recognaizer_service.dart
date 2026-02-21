import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class UniversalScannerService {
  // Initialize both engines
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final _barcodeScanner = BarcodeScanner();

  Future<Map<String, dynamic>> processImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);

    // Run both scanners in parallel for maximum speed
    final results = await Future.wait([
      _barcodeScanner.processImage(inputImage),
      _textRecognizer.processImage(inputImage),
    ]);

    final List<Barcode> barcodes = results[0] as List<Barcode>;
    final RecognizedText recognizedText = results[1] as RecognizedText;

    // --- 1. Process Barcode Data ---
    String? qrResult;
    if (barcodes.isNotEmpty) {
      final Barcode firstBarcode = barcodes.first;
      qrResult = firstBarcode.displayValue;
    }

    // --- 2. Process Text Data (Your Formatting Logic) ---
    StringBuffer textBuffer = StringBuffer();
    for (TextBlock block in recognizedText.blocks) {
      textBuffer.write(block.text);
      textBuffer.write("\n\n");
    }
    String? finalFullText = textBuffer.isEmpty
        ? null
        : textBuffer.toString().trim();

    // Return a Map so your Cubit can decide what to show
    return {'barcode': qrResult, 'text': finalFullText};
  }

  void dispose() {
    _textRecognizer.close();
    _barcodeScanner.close();
  }
}

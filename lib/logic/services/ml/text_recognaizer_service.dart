import 'dart:io';
import 'package:ai_partner/models/scan_result_model.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextRecognizerService {
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<VisionResult?> scan(File file) async {
    final inputImage = InputImage.fromFile(file);
    final recognizedText = await _recognizer.processImage(inputImage);

    if (recognizedText.text.trim().isEmpty) return null;

    return VisionResult(
      // Temporary ID, which will be finalized in the UniversalScannerService
      id: "txt_${DateTime.now().millisecondsSinceEpoch}",
      content: recognizedText.text,
      type: VisionType.text,
      label: "TEXT",
    );
  }

  void dispose() => _recognizer.close();
}

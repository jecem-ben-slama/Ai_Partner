import 'dart:io';
import 'package:ai_partner/data/models/scan_result_model.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextRecognizerService {
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<SmartResult?> scan(File file) async {
    final inputImage = InputImage.fromFile(file);
    final recognizedText = await _recognizer.processImage(inputImage);

    if (recognizedText.text.trim().isEmpty) return null;

    return SmartResult(
      content: recognizedText.text,
      type: ScanDataType.text,
      label: "TEXT",
    );
  }

  void dispose() => _recognizer.close();
}

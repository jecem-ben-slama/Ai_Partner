import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextRecognizerService {
  // Use the script that matches your target (Latin or Arabic)
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> processImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText = await _textRecognizer.processImage(
      inputImage,
    );

    if (recognizedText.text.isEmpty) {
      return "No text detected. Please try a clearer image.";
    }

    // --- NEW FORMATTING LOGIC START ---
    StringBuffer buffer = StringBuffer();

    for (TextBlock block in recognizedText.blocks) {
      // We use a StringBuffer for better performance when building long strings
      buffer.write(block.text);
      buffer.write("\n\n"); // Adds a double space between detected paragraphs
    }

    return buffer
        .toString()
        .trim(); // .trim() removes the extra space at the very end
    // --- NEW FORMATTING LOGIC END ---
  }

  void dispose() {
    _textRecognizer.close();
  }
}

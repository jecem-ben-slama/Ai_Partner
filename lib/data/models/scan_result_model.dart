enum ScanDataType { text, barcode }

class SmartResult {
  final String content;
  final ScanDataType type;
  final String? label; // e.g., "URL", "WiFi", "Paragraph"

  SmartResult({required this.content, required this.type, this.label});
}

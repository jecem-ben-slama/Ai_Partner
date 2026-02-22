class BarcodeModel {
  final String value;
  final String type; // e.g., URL, WIFI, PHONE, TEXT

  BarcodeModel({required this.value, required this.type});

  /// Helper to determine which icon to show in the UI
  bool get isUrl => type.contains('URL') || value.startsWith('http');
  bool get isWifi => type.contains('WIFI');
  bool get isPhone => type.contains('PHONE');

  /// Formats the label for a cleaner UI look (e.g., "WIFI" -> "WiFi")
  String get displayType {
    if (type == "QR_CODE") return "QR Code";
    return type[0] + type.substring(1).toLowerCase();
  }
}

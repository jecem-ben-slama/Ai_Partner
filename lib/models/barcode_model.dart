class BarcodeModel {
  final String value;
  final String type; // e.g., URL, WIFI, PHONE, TEXT

  BarcodeModel({required this.value, required this.type});

  /// Helper to determine which icon to show in the UI
  bool get isUrl => type.contains('URL') || value.startsWith('http');
  bool get isWifi => type.contains('WIFI');
 // Inside BarcodeModel class
  bool get isPhone {
    // Removes common formatting like +, -, spaces, or parentheses
    final cleanValue = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');

    // Checks if it consists only of digits and is between 3 to 15 digits long
    final isNumeric = RegExp(r'^\d+$').hasMatch(cleanValue);

    // ML Kit sometimes labels it as PHONE, or we can manually check numeric content
    return type == "PHONE" || (isNumeric && cleanValue.length >= 3);
  }

  /// Formats the label for a cleaner UI look (e.g., "WIFI" -> "WiFi")
  String get displayType {
    if (type == "QR_CODE") return "QR Code";
    return type[0] + type.substring(1).toLowerCase();
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'type': type};
  }

  /// Creates a BarcodeModel from a decoded JSON Map.
  factory BarcodeModel.fromJson(Map<String, dynamic> json) {
    return BarcodeModel(
      value: json['value'] ?? '',
      type: json['type'] ?? 'TEXT',
    );
  }
}

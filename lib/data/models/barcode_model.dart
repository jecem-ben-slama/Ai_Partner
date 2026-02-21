import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

enum ScannedType { url, wifi, text, product, email }

class BarcodeModel {
  final String displayValue;
  final ScannedType type;
  final String? rawData;

  BarcodeModel({required this.displayValue, required this.type, this.rawData});

  // Factory to convert ML Kit result to our clean model
  factory BarcodeModel.fromMlKit(Barcode barcode) {
    ScannedType type;

    switch (barcode.type) {
      case BarcodeType.url:
        type = ScannedType.url;
        break;
      case BarcodeType.wifi:
        type = ScannedType.wifi;
        break;
      case BarcodeType.product:
        type = ScannedType.product;
        break;
      case BarcodeType.email:
        type = ScannedType.email;
        break;
      default:
        type = ScannedType.text;
    }

    return BarcodeModel(
      displayValue: barcode.displayValue ?? "Unknown",
      type: type,
      rawData: barcode.rawValue,
    );
  }
}

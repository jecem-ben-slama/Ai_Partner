enum VisionType { text, url, phone, barcode, qr }

class VisionResult {
  final String id;
  final String content;
  final VisionType type;
  final String? label;

  VisionResult({
    required this.id,
    required this.content,
    required this.type,
    this.label,
  });

  factory VisionResult.fromJson(Map<String, dynamic> json) {
    return VisionResult(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      label: json['label'],
      type: VisionType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => VisionType.text,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'label': label,
      'type': type.toString(),
    };
  }
}

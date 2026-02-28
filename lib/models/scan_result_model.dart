enum VisionType { text, url, phone, barcode, qr }

class VisionResult {
  final String id; // Added ID
  final String content;
  final VisionType type;
  final String? label;
  final bool isFavorite;

  VisionResult({
    required this.id, // ID is now required
    required this.content,
    required this.type,
    this.label,
    this.isFavorite = false,
  });

  VisionResult copyWith({
    String? id, // Allow copying the ID
    String? label,
    String? content,
    VisionType? type,
    bool? isFavorite,
  }) {
    return VisionResult(
      id: id ?? this.id, // Preserve the ID
      content: content ?? this.content,
      type: type ?? this.type,
      label: label ?? this.label,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Save ID
      'content': content,
      'type': type.name,
      'label': label,
      'isFavorite': isFavorite,
    };
  }

  factory VisionResult.fromJson(Map<String, dynamic> json) {
    return VisionResult(
      // Ensure we provide a fallback ID for old data to prevent crashes
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: json['content'] as String,
      type: VisionType.values.byName(json['type'] as String),
      label: json['label'] as String?,
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}

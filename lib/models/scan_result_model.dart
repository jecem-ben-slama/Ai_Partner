// ignore: depend_on_referenced_packages
import 'package:uuid/uuid.dart';

enum VisionType { text, url, phone, barcode, qr }

class VisionResult {
  final String id;
  final String content;
  final VisionType type;
  final String? label;
  final bool isFavorite;

  VisionResult({
    required this.id,
    required this.content,
    required this.type,
    this.label,
    this.isFavorite = false,
  });

  /// NEW: A factory to create a result with an automatic ID.
  /// Use this when first scanning an item.
  factory VisionResult.createNew({
    required String content,
    required VisionType type,
    String? label,
    bool isFavorite = false,
  }) {
    return VisionResult(
      id: const Uuid().v4(), // Generates a unique client-side ID immediately
      content: content,
      type: type,
      label: label,
      isFavorite: isFavorite,
    );
  }

  VisionResult copyWith({
    String? id,
    String? label,
    String? content,
    VisionType? type,
    bool? isFavorite,
  }) {
    return VisionResult(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      label: label ?? this.label,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'label': label,
      'isFavorite': isFavorite,
    };
  }

  factory VisionResult.fromJson(Map<String, dynamic> json) {
    return VisionResult(
      // Check for 'id' first, fallback to a timestamp if loading old legacy data
      id:
          json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      content: json['content'] as String,
      type: VisionType.values.byName(json['type'] as String),
      label: json['label'] as String?,
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}

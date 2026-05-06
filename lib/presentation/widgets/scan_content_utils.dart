import 'package:flutter/material.dart';
import 'package:ai_partner/models/scan_result_model.dart';

// ─────────────────────────────────────────────────────────────
// BASIC DETECTION HELPERS
// ─────────────────────────────────────────────────────────────

bool isProbablyPhone(String input) {
  final clean = input.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  return RegExp(r'^\+?[0-9]{7,15}$').hasMatch(clean);
}

bool isProbablyUrl(String input) {
  final lower = input.toLowerCase();
  return lower.startsWith('http://') ||
      lower.startsWith('https://') ||
      lower.startsWith('www.');
}

bool isProbablyEmail(String input) =>
    RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$').hasMatch(input.trim());

// ─────────────────────────────────────────────────────────────
// WIFI DETECTION (QR + OCR FIX)
// ─────────────────────────────────────────────────────────────

bool isWifiQr(String input) =>
    input.trimLeft().toUpperCase().startsWith('WIFI:');

bool isProbablyWifi(String input) {
  final text = input.toLowerCase();

  // QR standard format
  if (text.startsWith('wifi:')) return true;

  // OCR fallback detection (IMPORTANT FIX)
  final hasWifiKeyword =
      text.contains('wifi') ||
      text.contains('wlan') ||
      text.contains('ssid') ||
      text.contains('network');

  // must look like credential/token
  final hasCredentialPattern = RegExp(r'[a-zA-Z0-9]{6,}').hasMatch(text);

  return hasWifiKeyword && hasCredentialPattern;
}

// ─────────────────────────────────────────────────────────────
// WIFI QR PARSER
// ─────────────────────────────────────────────────────────────

Map<String, String> parseWifiQr(String input) {
  final result = <String, String>{};

  final body = input
      .replaceFirst(RegExp(r'^wifi:', caseSensitive: false), '')
      .replaceAll(RegExp(r';;$'), '');

  for (final part in body.split(';')) {
    final idx = part.indexOf(':');
    if (idx != -1) {
      result[part.substring(0, idx).toUpperCase()] = part.substring(idx + 1);
    }
  }

  return result;
}

// ─────────────────────────────────────────────────────────────
// FLAGS SYSTEM (MAIN LOGIC FIXED)
// ─────────────────────────────────────────────────────────────
class ScanFlags {
  final bool isPhone;
  final bool isUrl;
  final bool isEmail;
  final bool isWifi;
  final bool canTranslate;
  final bool canTts;
  final VisionType type;

  const ScanFlags._({
    required this.isPhone,
    required this.isUrl,
    required this.isEmail,
    required this.isWifi,
    required this.canTranslate,
    required this.canTts,
    required this.type,
  });

  factory ScanFlags.from({required String content, required VisionType type}) {
    final text = content.trim();

    final phone = isProbablyPhone(text);
    final url = isProbablyUrl(text);
    final email = isProbablyEmail(text);
    final wifi = isWifiQr(text) || isProbablyWifi(text);

    final isSpecial = phone || url || email || wifi;

    return ScanFlags._(
      isPhone: phone,
      isUrl: url,
      isEmail: email,
      isWifi: wifi,
      type: type,

      // 🔥 FIX 1: Translate should depend on content, not type only
      canTranslate: !isSpecial && text.length > 2,

      // 🔥 FIX 2: TTS should ALWAYS work for readable text
      canTts: !isSpecial && text.length > 0,
    );
  }

  IconData get icon {
    if (isWifi) return Icons.wifi;
    if (isPhone) return Icons.phone;
    if (isEmail) return Icons.email_outlined;

    switch (type) {
      case VisionType.url:
        return Icons.language;
      case VisionType.barcode:
        return Icons.qr_code_2;
      case VisionType.qr:
        return Icons.qr_code;
      default:
        return Icons.text_fields;
    }
  }
}

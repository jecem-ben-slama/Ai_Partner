// lib/presentation/widgets/wifi_service.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'scan_content_utils.dart';

const MethodChannel _channel = MethodChannel('wifi_connector');

/// ─────────────────────────────────────────────
/// CONNECT WIFI
/// ─────────────────────────────────────────────
Future<void> connectToWifi(
  BuildContext context,
  String content, {
  required void Function(String) onNotify,
}) async {
  debugPrint("📡 WIFI CONNECT START");

  final wifiData = parseWifiQr(content);
  final ssid = wifiData['S'] ?? '';
  final password = wifiData['P'] ?? '';

  debugPrint("📶 SSID: $ssid");
  debugPrint("🔑 PASSWORD: $password");

  if (ssid.isEmpty) {
    debugPrint("❌ Invalid WiFi QR");
    onNotify('Invalid Wi-Fi QR code');
    return;
  }

  /// 🍏 iOS fallback
  if (Platform.isIOS) {
    final uri = Uri.parse('app-settings:');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
    return;
  }

  /// 🤖 Android permission
  final status = await Permission.location.request();
  if (!status.isGranted) {
    debugPrint("❌ Location denied");
    onNotify('Location permission required');
    return;
  }

  try {
    debugPrint("📡 Calling native WiFi connector...");

    final result = await _channel.invokeMethod('connectWifi', {
      'ssid': ssid,
      'password': password,
    });

    debugPrint("📥 Native result: $result");

    if (result == true) {
      onNotify('System WiFi popup opened');
    } else {
      _openWifiSettings();
      onNotify('Opening Wi-Fi settings...');
    }
  } catch (e) {
    debugPrint("❌ Channel error: $e");
    _openWifiSettings();
    onNotify('Error → opening Wi-Fi settings');
  }
}

/// ─────────────────────────────────────────────
/// OPEN WIFI SETTINGS (FIXED)
/// ─────────────────────────────────────────────
Future<void> _openWifiSettings() async {
  debugPrint("⚙️ Opening WiFi settings");

  final uri = Uri.parse('android.settings.panel.action.WIFI');
  // fallback modern Android intent

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    // final fallback
    await launchUrl(Uri.parse('package:com.android.settings'));
  }
}

/// ─────────────────────────────────────────────
/// WIFI DIALOG
/// ─────────────────────────────────────────────
void showWifiDialog(
  BuildContext context,
  String content, {
  required void Function(String) onNotify,
}) {
  final wifiData = parseWifiQr(content);
  final ssid = wifiData['S'] ?? 'Unknown';
  final password = wifiData['P'] ?? '';
  final type = wifiData['T'] ?? 'WPA';

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.wifi, size: 20),
          SizedBox(width: 8),
          Text('Wi-Fi Network'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _wifiRow(context, 'Network', ssid),
          if (password.isNotEmpty) _wifiRow(context, 'Password', password),
          _wifiRow(context, 'Security', type),

          if (password.isNotEmpty) ...[
            const SizedBox(height: 16),
            _copyPasswordButton(
              context,
              password,
              onTap: () {
                Clipboard.setData(ClipboardData(text: password));
                Navigator.pop(ctx);
                onNotify('Password copied!');
              },
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            connectToWifi(context, content, onNotify: onNotify);
          },
          child: const Text('Connect'),
        ),
      ],
    ),
  );
}

/// ─────────────────────────────────────────────
/// UI HELPERS
/// ─────────────────────────────────────────────
Widget _wifiRow(BuildContext context, String label, String value) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: Row(
    children: [
      SizedBox(
        width: 72,
        child: Text(
          '$label:',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      Expanded(child: Text(value)),
    ],
  ),
);

Widget _copyPasswordButton(
  BuildContext context,
  String password, {
  required VoidCallback onTap,
}) => InkWell(
  onTap: onTap,
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.copy,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 6),
        Text(
          'Copy password',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ],
    ),
  ),
);

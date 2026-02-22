import 'package:ai_partner/data/models/barcode_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class BarcodeCard extends StatelessWidget {
  final BarcodeModel barcode;
  const BarcodeCard({super.key, required this.barcode});
Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF364156),
      clipBehavior: Clip.antiAlias, // Smooth edges
      child: ExpansionTile(
        collapsedIconColor: Colors.white70,
        iconColor: Theme.of(context).colorScheme.primary,
        leading: Icon(
          barcode.isUrl
              ? Icons.language
              : barcode.isPhone
              ? Icons.phone
              : Icons.qr_code_2,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          barcode.displayType,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          barcode.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white70),
        ),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.black12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 1. Copy Button (Always present)
                _ActionButton(
                  icon: Icons.copy,
                  label: "Copy",
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: barcode.value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Copied to clipboard!")),
                    );
                  },
                ),

                // 2. Conditional: Call Button
                if (barcode.isPhone)
                  _ActionButton(
                    icon: Icons.call,
                    label: "Call",
                    onTap: () => _launch("tel:${barcode.value}"),
                  ),

                // 3. Conditional: Browser Button
                if (barcode.isUrl)
                  _ActionButton(
                    icon: Icons.open_in_browser,
                    label: "Chrome",
                    onTap: () => _launch(barcode.value),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Small helper for the buttons inside the expanded area
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

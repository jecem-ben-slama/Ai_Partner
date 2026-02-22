import 'package:ai_partner/data/models/barcode_model.dart';
import 'package:ai_partner/logic/storage_service/history_cubit.dart';
import 'package:ai_partner/logic/storage_service/storage_service.dart';
import 'package:ai_partner/presentation/widgets/action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                ActionButton(
                  icon: Icons.bookmark_add_outlined,
                  label: "Save",
                  onTap: () {
                    // Trigger the HistoryCubit save logic
                    context.read<HistoryCubit>().saveNewScan(
                      null, // Since this card represents a single barcode
                      [barcode],
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Added to History")),
                    );
                  },
                ),
                // 1. Copy Button (Always present)
                ActionButton(
                  icon: Icons.copy,
                  label: "Copy",
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: barcode.value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Copied to clipboard!")),
                    );
                  },
                ),
                ActionButton(
                  icon: Icons.save,
                  label: "Save",
                  onTap: () async {
                    await StorageService().saveScan(barcode.value, [barcode]);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Scan saved to history!")),
                    );
                  },
                ),
                // 2. Conditional: Call Button
                if (barcode.isPhone)
                  ActionButton(
                    icon: Icons.call,
                    label: "Call",
                    onTap: () => _launch("tel:${barcode.value}"),
                  ),

                // 3. Conditional: Browser Button
                if (barcode.isUrl)
                  ActionButton(
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

/* import 'package:ai_partner/models/barcode_model.dart';
import 'package:ai_partner/logic/cubit/storage/history_cubit.dart';
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
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        collapsedIconColor: Colors.white70,
        iconColor: Theme.of(context).colorScheme.primary,
        leading: Icon(
          barcode.isUrl
              ? Icons.language
              : barcode
                    .isPhone // Now uses our new logic
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
                // 1. Save Button (History)
                ActionButton(
                  icon: Icons.bookmark_add_outlined,
                  label: "Save",
                  onTap: () {
                    context.read<HistoryCubit>().saveNewScan(null, [barcode]);
                    _showFloatingSnackBar(context, "Added to History");
                  },
                ),
                // 2. Copy Button
                ActionButton(
                  icon: Icons.copy,
                  label: "Copy",
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: barcode.value));
                    _showFloatingSnackBar(context, "Copied to clipboard!");
                  },
                ),
                // 3. Conditional: Call Button (Appears if isPhone is true)
                if (barcode.isPhone)
                  ActionButton(
                    icon: Icons.call,
                    label: "Call",
                    onTap: () => _launch("tel:${barcode.value}"),
                  ),
                // 4. Conditional: Browser Button
                if (barcode.isUrl)
                  ActionButton(
                    icon: Icons.open_in_browser,
                    label: "Open",
                    onTap: () => _launch(barcode.value),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper for that floating snackbar we discussed!
  void _showFloatingSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
      ),
    );
  }
}
 */
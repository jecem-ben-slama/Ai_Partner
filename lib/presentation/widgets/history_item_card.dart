import 'package:ai_partner/data/models/barcode_model.dart';
import 'package:ai_partner/logic/storage_service/history_cubit.dart';
import 'package:ai_partner/presentation/screens/translator_screen.dart';
import 'package:ai_partner/presentation/widgets/action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class HistoryItemCard extends StatelessWidget {
  final Map<String, dynamic> scan;

  const HistoryItemCard({super.key, required this.scan});

  // Helper to open URLs
  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // --- The Popup Logic ---
  void _showScanDetail(BuildContext context, Map<String, dynamic> scan) {
    final String? text = scan['text'];
    final List<dynamic> barcodeData = scan['barcodes'] ?? [];
    final barcodes = barcodeData.map((b) => BarcodeModel.fromJson(b)).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161925),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 40,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                text != null ? "Text Scan" : "Barcode Detail",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (text != null)
                SelectableText(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              if (barcodes.isNotEmpty)
                ...barcodes.map(
                  (b) => Text(
                    "${b.displayType}: ${b.value}",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Copy
                  ActionButton(
                    icon: Icons.copy,
                    label: "Copy",
                    onTap: () {
                      final content =
                          text ??
                          (barcodes.isNotEmpty ? barcodes.first.value : "");
                      Clipboard.setData(ClipboardData(text: content));
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Copied to clipboard")),
                      );
                    },
                  ),
                  // Translate
                  //only show translate if it's a text scan or a barcode with non-URL content
                  if (text != null ||
                      (barcodes.isNotEmpty && !barcodes.first.isUrl))
                    ActionButton(
                      icon: Icons.g_translate_rounded,
                      label: "Translate",
                      onTap: () {
                        // 1. Close the bottom sheet first
                        Navigator.pop(sheetContext);

                        // 2. Navigate to the Translator Screen with the text
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TranslatorScreen(
                              initialText: text ?? barcodes.first.value,
                            ),
                          ),
                        );
                      },
                    ),
                  // Share
                  ActionButton(
                    icon: Icons.share_outlined,
                    label: "Share",
                    onTap: () {
                      final content =
                          text ??
                          (barcodes.isNotEmpty ? barcodes.first.value : "");
                      if (content.isNotEmpty) {
                        // Use the static helper - it's the safest way to avoid the 'ShareParams' error
                        Share.share(content);
                      }
                      Navigator.pop(sheetContext);
                    },
                  ),
                  // Open Link
                  if (barcodes.isNotEmpty && barcodes.first.isUrl)
                    ActionButton(
                      icon: Icons.open_in_browser,
                      label: "Open",
                      onTap: () {
                        _launch(barcodes.first.value);
                        Navigator.pop(sheetContext);
                      },
                    ),
                  // Delete
                  ActionButton(
                    icon: Icons.delete_outline,
                    label: "Remove",
                    onTap: () {
                      Navigator.pop(sheetContext); // Close sheet first
                      _showDeleteConfirm(context); // Then show confirm dialog
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime date = DateTime.parse(scan['timestamp']);
    final String? text = scan['text'];
    final List<dynamic> barcodeData = scan['barcodes'] ?? [];
    final barcodes = barcodeData.map((b) => BarcodeModel.fromJson(b)).toList();

    return Card(
      color: const Color(0xFF364156),
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showScanDetail(context, scan),
        child: ListTile(
          leading: Icon(
            text != null ? Icons.text_snippet : Icons.qr_code,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            text ??
                (barcodes.isNotEmpty ? barcodes.first.value : "Scan Result"),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          subtitle: Text(
            DateFormat('MMM dd • HH:mm').format(date),
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.white24,
            size: 18,
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF161925),
        title: const Text(
          "Remove Scan?",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Are you sure you want to delete this specific scan?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final String? id = scan['id'];
              if (id != null) {
                context.read<HistoryCubit>().deleteItem(id);
                Navigator.pop(dialogContext);
              } else {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Cannot delete old items without IDs."),
                  ),
                );
              }
            },
            child: const Text("Remove", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

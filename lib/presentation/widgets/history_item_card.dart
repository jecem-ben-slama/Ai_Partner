import 'package:ai_partner/models/scan_result_model.dart'; // Unified model
import 'package:ai_partner/logic/cubit/storage/history_cubit.dart';
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

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // --- The Detail Popup Logic ---
  void _showScanDetail(BuildContext context, List<VisionResult> results) {
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
          top: 15,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 40,
        ),
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
            const SizedBox(height: 25),
            Text(
              "History Detail",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 15),

            // Render all results found in this scan session
            ...results.map(
              (res) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    res.label ?? "Result",
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    res.content,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  _buildActionRow(context, sheetContext, res),
                  const Divider(color: Colors.white10, height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow(
    BuildContext context,
    BuildContext sheetContext,
    VisionResult res,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ActionButton(
            icon: Icons.copy,
            label: "Copy",
            onTap: () {
              Clipboard.setData(ClipboardData(text: res.content));
              Navigator.pop(sheetContext);
              _showFloatingSnack(context, "Copied to clipboard");
            },
          ),
          if (res.type == VisionType.text || res.type == VisionType.barcode)
            ActionButton(
              icon: Icons.g_translate_rounded,
              label: "Translate",
              onTap: () {
                Navigator.pop(sheetContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TranslatorScreen(initialText: res.content),
                  ),
                );
              },
            ),
          if (res.type == VisionType.phone)
            ActionButton(
              icon: Icons.call,
              label: "Call",
              onTap: () => _launch("tel:${res.content}"),
            ),
          if (res.type == VisionType.url)
            ActionButton(
              icon: Icons.open_in_browser,
              label: "Open",
              onTap: () => _launch(res.content),
            ),
          ActionButton(
            icon: Icons.share_outlined,
            label: "Share",
            onTap: () => Share.share(res.content),
          ),
          ActionButton(
            icon: Icons.delete_outline,
            label: "Remove",
            onTap: () {
              Navigator.pop(sheetContext);
              _showDeleteConfirm(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime date = DateTime.parse(scan['timestamp']);

    // Parse the new results structure
    final List<dynamic> rawResults = scan['results'] ?? [];
    final List<VisionResult> results = rawResults
        .map((r) => VisionResult.fromJson(r))
        .toList();

    // Default preview text
    final String previewText = results.isNotEmpty
        ? results.first.content
        : "Empty Scan";
    final IconData previewIcon =
        results.isNotEmpty && results.first.type == VisionType.text
        ? Icons.text_snippet_outlined
        : Icons.qr_code_2;

    return Card(
      color: const Color(0xFF364156),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showScanDetail(context, results),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              previewIcon,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(
            previewText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              DateFormat('MMM dd • HH:mm').format(date),
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white12,
            size: 14,
          ),
        ),
      ),
    );
  }

  void _showFloatingSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
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
          "Delete this scan from history?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<HistoryCubit>().deleteItem(scan['id']);
              Navigator.pop(dialogContext);
            },
            child: const Text(
              "Remove",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

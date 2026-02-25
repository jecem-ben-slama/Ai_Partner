import 'package:ai_partner/core/theme/app_colors.dart';
import 'package:ai_partner/models/scan_result_model.dart';
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

  // Helper to detect phone numbers in plain text (Handles spaces, dashes, parentheses)
  bool _isProbablyPhone(String input) {
    final cleanInput = input.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return RegExp(r'^\+?[0-9]{7,15}$').hasMatch(cleanInput);
  }

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
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppColors.primaryLight,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 15),

            // Render all results found in this scan session
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: results
                    .map(
                      (res) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            res.label ?? "Result",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SelectableText(
                            res.content,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildActionRow(context, sheetContext, res),
                          Divider(
                            color: Theme.of(
                              context,
                            ).colorScheme.outlineVariant.withOpacity(0.2),
                            height: 30,
                          ),
                        ],
                      ),
                    )
                    .toList(),
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
    // Check if type is phone OR if the content matches phone regex
    final bool showCallAction =
        res.type == VisionType.phone || _isProbablyPhone(res.content);

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

          // SMART CALL BUTTON
          if (showCallAction)
            ActionButton(
              icon: Icons.call,
              label: "Call",
              onTap: () => _launch(
                "tel:${res.content.replaceAll(RegExp(r'[\s\-\(\)]'), '')}",
              ),
            ),

          if (res.type == VisionType.text ||
              res.type == VisionType.barcode ||
              res.type == VisionType.qr)
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

    // Determine the preview icon and text
    final bool firstIsPhone =
        results.isNotEmpty && _isProbablyPhone(results.first.content);

    final String previewText = results.isNotEmpty
        ? results.first.content
        : "Empty Scan";

    final IconData previewIcon = firstIsPhone
        ? Icons.phone
        : (results.isNotEmpty && results.first.type == VisionType.text
              ? Icons.text_snippet_outlined
              : Icons.qr_code_2);

    return Card(
      color: Theme.of(context).colorScheme.surface,
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
              color: Colors.white70,

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
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              DateFormat('MMM dd • HH:mm').format(date),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: Theme.of(context).colorScheme.onTertiary,
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
        backgroundColor: const Color(0xFF161925),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("Remove Scan?"),
        content: const Text("Delete this scan from history?"),
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

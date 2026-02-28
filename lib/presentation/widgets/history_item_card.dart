import 'package:ai_partner/core/theme/app_colors.dart';
import 'package:ai_partner/models/scan_result_model.dart';
import 'package:ai_partner/logic/cubit/storage/history_cubit.dart';
import 'package:ai_partner/presentation/screens/translator_screen.dart';
import 'package:ai_partner/presentation/screens/tts_player_page.dart';
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

  void _showRenameDialog(
    BuildContext context,
    String currentLabel,
    String scanId,
  ) {
    final TextEditingController renameController = TextEditingController(
      text: currentLabel,
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("Rename Scan"),
        content: TextField(
          controller: renameController,
          autofocus: true,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: "Enter new name",
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              "Cancel",
              style: TextStyle(
                color:
                    Theme.of(context).colorScheme.brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final newName = renameController.text.trim();
              if (newName.isNotEmpty) {
                context.read<HistoryCubit>().updateLabel(scanId, newName);
              }
              Navigator.pop(dialogContext);
            },
            child: Text(
              "Save",
              style: TextStyle(
                color:
                    Theme.of(context).colorScheme.brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: results.map((res) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        res.label?.toUpperCase() ?? "RESULT",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
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
                        color: Theme.of(context).colorScheme.outlineVariant,
                        height: 30,
                      ),
                    ],
                  );
                }).toList(),
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
    // Logic for conditional visibility
    final bool hasContent = res.content.trim().isNotEmpty;
    final bool isPureText =
        res.type == VisionType.text; // Strict check for text
    final bool isPhone =
        res.type == VisionType.phone || _isProbablyPhone(res.content);
    final bool isUrl =
        res.type == VisionType.url || res.content.startsWith('http');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // TTS - ONLY WHEN TEXT
          if (hasContent && isPureText)
            ActionButton(
              icon: Icons.volume_up_rounded,
              onTap: () {
                Navigator.pop(sheetContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TtsPlayerPage(text: res.content),
                  ),
                );
              },
            ),

          // RENAME
          ActionButton(
            icon: Icons.edit_outlined,
            onTap: () {
              Navigator.pop(sheetContext);
              _showRenameDialog(context, res.label ?? "", scan['id']);
            },
          ),

          // COPY
          if (hasContent)
            ActionButton(
              icon: Icons.copy,
              onTap: () {
                Clipboard.setData(ClipboardData(text: res.content));
                Navigator.pop(sheetContext);
                _showTopNotification(context, "coped");
              },
            ),

          // CALL
          if (isPhone)
            ActionButton(
              icon: Icons.call,
              onTap: () => _launch(
                "tel:${res.content.replaceAll(RegExp(r'[^\d+]'), '')}",
              ),
            ),

          // TRANSLATE - ONLY WHEN TEXT
          if (hasContent && isPureText)
            ActionButton(
              icon: Icons.g_translate_rounded,
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

          // OPEN BROWSER
          if (isUrl)
            ActionButton(
              icon: Icons.open_in_browser,
              onTap: () => _launch(res.content),
            ),

          // SHARE
          if (hasContent)
            ActionButton(
              icon: Icons.share_outlined,
              onTap: () => Share.share(res.content),
            ),

          // DELETE
          ActionButton(
            icon: Icons.delete_outline,
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
    final List<dynamic> rawResults = scan['results'] ?? [];
    final List<VisionResult> results = rawResults
        .map((r) => VisionResult.fromJson(r))
        .toList();

    final bool isFavorite = results.isNotEmpty && results.first.isFavorite;

    final String itemTitle = results.isNotEmpty
        ? (results.first.label ?? "Untitled Scan")
        : "Empty Scan";

    final String itemSubtitle = results.isNotEmpty
        ? results.first.content.replaceAll('\n', ' ')
        : "";

    final bool firstIsPhone =
        results.isNotEmpty && _isProbablyPhone(results.first.content);

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
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              previewIcon,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(
            itemTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (itemSubtitle.isNotEmpty)
                Text(
                  itemSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM dd • HH:mm').format(date),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          trailing: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              IconButton(
                onPressed: () {
                  context.read<HistoryCubit>().toggleFavorite(scan['id']);
                },
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite
                      ? Colors.redAccent
                      : Theme.of(context).colorScheme.outline,
                  size: 22,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.outline,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTopNotification(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF161925),
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.greenAccent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(message, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Remove it after 2 seconds
    Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
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

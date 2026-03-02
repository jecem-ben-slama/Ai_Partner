import 'package:ai_partner/l10n/app_localizations.dart';
import 'package:ai_partner/logic/services/haptic_service.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Data Parsing
    final DateTime date = DateTime.parse(
      scan['timestamp'] ?? DateTime.now().toString(),
    );
    final List<VisionResult> results = (scan['results'] as List? ?? [])
        .map((r) => VisionResult.fromJson(r))
        .toList();

    if (results.isEmpty) return const SizedBox.shrink();

    final firstRes = results.first;
    final bool isFavorite = firstRes.isFavorite;

    return Dismissible(
      key: Key('dismiss_${scan['id']}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        _showDeleteConfirm(context);
        context.read<HapticService>().triggerSuccess();
        return null;
      },
      background: _buildDeleteBackground(),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.dividerColor),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showScanDetail(context, results, l10n),
          onLongPress: () {
            context.read<HapticService>().triggerLoading();

            _showRenameDialog(context, firstRes.label ?? "", scan['id'], l10n);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                _buildLeadingIcon(context, firstRes),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstRes.label ?? "Untitled",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        firstRes.content.replaceAll('\n', ' '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('MMM dd • HH:mm').format(date),
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildTrailingActions(context, scan['id'], isFavorite),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets for Clarity ---

  Widget _buildLeadingIcon(BuildContext context, VisionResult res) {
    IconData iconData = Icons.text_snippet_outlined;
    if (res.type == VisionType.url) iconData = Icons.link_rounded;
    if (res.type == VisionType.phone) iconData = Icons.phone_enabled_rounded;
    if (res.type == VisionType.barcode) iconData = Icons.qr_code_rounded;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconData,
        color: Theme.of(context).colorScheme.primary,
        size: 24,
      ),
    );
  }

  Widget _buildTrailingActions(BuildContext context, String id, bool isFav) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            context.read<HapticService>().trigger;
            context.read<HistoryCubit>().toggleFavorite(id);
          },
          icon: Icon(
            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFav ? Colors.redAccent : Colors.grey,
            size: 22,
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
      ],
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
    );
  }

  // --- Utility Methods ---

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showScanDetail(
    BuildContext context,
    List<VisionResult> results,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                itemCount: results.length,
                separatorBuilder: (_, _) => const Divider(height: 40),
                itemBuilder: (ctx, i) =>
                    _buildDetailItem(context, sheetContext, results[i], l10n),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    BuildContext sheetCtx,
    VisionResult res,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          res.label?.toUpperCase() ?? "CONTENT",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        SelectableText(
          res.content,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 16),
        _buildActionRow(context, sheetCtx, res, l10n),
      ],
    );
  }

  Widget _buildActionRow(
    BuildContext context,
    BuildContext sheetCtx,
    VisionResult res,
    AppLocalizations l10n,
  ) {
    final bool isText = res.type == VisionType.text;
    final bool isUrl =
        res.type == VisionType.url || res.content.startsWith('http');
    final bool isPhone = res.type == VisionType.phone;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        if (isText)
          ActionButton(
            icon: Icons.g_translate_rounded,
            onTap: () {
              Navigator.pop(sheetCtx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => TranslatorScreen(initialText: res.content),
                ),
              );
            },
          ),
        if (isText)
          ActionButton(
            icon: Icons.volume_up_rounded,
            onTap: () {
              Navigator.pop(sheetCtx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => TtsPlayerPage(text: res.content),
                ),
              );
            },
          ),
        if (isUrl)
          ActionButton(
            icon: Icons.open_in_browser_rounded,
            onTap: () => _launch(res.content),
          ),
        if (isPhone)
          ActionButton(
            icon: Icons.call_rounded,
            onTap: () => _launch("tel:${res.content}"),
          ),
        ActionButton(
          icon: Icons.copy_rounded,
          onTap: () {
            Clipboard.setData(ClipboardData(text: res.content));
            Navigator.pop(sheetCtx);
            _showTopNotification(context, l10n.copiedLabel);
          },
        ),
        ActionButton(
          icon: Icons.share_rounded,
          // ignore: deprecated_member_use
          onTap: () => Share.share(res.content),
        ),
      ],
    );
  }

  Future<bool> _showDeleteConfirm(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.clearscanTitle),
        content: Text(l10n.clearscanMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<HistoryCubit>().deleteItem(
                scan['id'],
                errorMessage: l10n.deleteError,
              );
              Navigator.pop(ctx, true);
            },
            child: Text(
              l10n.confirm,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
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
    Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
  }

  void _showRenameDialog(
    BuildContext context,
    String currentLabel,
    String scanId,
    AppLocalizations l10n,
  ) {
    final controller = TextEditingController(text: currentLabel);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.renameScanLabel),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<HapticService>().trigger;

                context.read<HistoryCubit>().updateLabel(
                  scanId,
                  controller.text.trim(),
                );
              }
              Navigator.pop(ctx);
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }
}

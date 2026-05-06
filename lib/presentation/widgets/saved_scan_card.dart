// ignore_for_file: deprecated_member_use

import 'package:ai_partner/core/l10n/app_localizations.dart';
import 'package:ai_partner/logic/services/haptic_service.dart';
import 'package:ai_partner/logic/services/sound_service.dart';
import 'package:ai_partner/models/scan_result_model.dart';
import 'package:ai_partner/logic/cubit/saved_scan/saved_scan_cubit.dart';
import 'package:ai_partner/presentation/screens/translator_screen.dart';
import 'package:ai_partner/presentation/screens/tts_player_page.dart';
import 'package:ai_partner/presentation/widgets/action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SavedScanCard extends StatelessWidget {
  final VisionResult scan; // The model you provided

  const SavedScanCard({super.key, required this.scan});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Since 'scan' is a VisionResult, we use its properties directly
    final bool isFavorite = scan.isFavorite;
    final String displayLabel = scan.label ?? "Untitled";
    final String displayContent = scan.content.replaceAll('\n', ' ');

    return Dismissible(
      key: Key('dismiss_${scan.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final confirmed = await _showDeleteConfirm(context);
        if (confirmed) {
          // ignore: use_build_context_synchronously
          context.read<HapticService>().triggerSuccess();
        }
        return confirmed;
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
          onTap: () => _showScanDetail(context, scan, l10n),
          onLongPress: () {
            context.read<HapticService>().triggerLoading();
            _showRenameDialog(context, scan.label ?? "", scan.id, l10n);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                _buildLeadingIcon(context, scan.type),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        displayContent,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildTrailingActions(context, scan.id, isFavorite),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(BuildContext context, VisionType type) {
    IconData iconData;
    switch (type) {
      case VisionType.url:
        iconData = Icons.language;
        break;
      case VisionType.phone:
        iconData = Icons.phone;
        break;
      case VisionType.barcode:
        iconData = Icons.qr_code_2;
        break;
      case VisionType.qr:
        iconData = Icons.qr_code;
        break;
      default:
        iconData = Icons.text_snippet_outlined;
    }

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
            context.read<HapticService>().trigger();
            context.read<SavedScanCubit>().toggleFavorite(id);
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

  void _showScanDetail(
    BuildContext context,
    VisionResult result,
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
        initialChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                result.label?.toUpperCase() ?? "CONTENT",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              SelectableText(
                result.content,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 24),
              _buildActionRow(context, sheetContext, result, l10n),
            ],
          ),
        ),
      ),
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
        if (isText ||
            res.type == VisionType.barcode ||
            res.type == VisionType.qr)
          ActionButton(
            icon: Icons.g_translate_rounded,
            onTap: () {
              context.read<SoundService>().playTap();
              context.read<HapticService>().trigger();
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
            icon: Icons.record_voice_over_rounded,
            onTap: () {
              context.read<SoundService>().playTap();
              context.read<HapticService>().trigger();
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
            onTap: () async {
              final uri = Uri.parse(res.content);
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
          ),
        if (isPhone)
          ActionButton(
            icon: Icons.call_rounded,
            onTap: () async {
              final uri = Uri.parse(
                "tel:${res.content.replaceAll(RegExp(r'\s+'), '')}",
              );
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
          ),
        ActionButton(
          icon: Icons.copy_rounded,
          onTap: () {
            Clipboard.setData(ClipboardData(text: res.content));
            context.read<HapticService>().trigger();
            Navigator.pop(sheetCtx);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.copiedLabel)));
          },
        ),
        ActionButton(
          icon: Icons.share_rounded,
          onTap: () => Share.share(res.content),
        ),
      ],
    );
  }

  Future<bool> _showDeleteConfirm(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    return await showDialog<bool>(
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
                  context.read<SavedScanCubit>().deleteItem(
                    scan.id,
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
        ) ??
        false;
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
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.nameLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<SavedScanCubit>().updateLabel(
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

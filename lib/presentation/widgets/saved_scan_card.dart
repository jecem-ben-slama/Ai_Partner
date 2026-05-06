// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:ai_partner/core/l10n/app_localizations.dart';
import 'package:ai_partner/logic/cubit/saved_scan/saved_scan_cubit.dart';
import 'package:ai_partner/logic/services/haptic_service.dart';
import 'package:ai_partner/logic/services/sound_service.dart';
import 'package:ai_partner/models/scan_result_model.dart';
import 'package:ai_partner/presentation/screens/translator_screen.dart';
import 'package:ai_partner/presentation/screens/tts_player_page.dart';
import 'package:ai_partner/presentation/widgets/action_button.dart';
import 'package:ai_partner/presentation/widgets/scan_content_utils.dart';
import 'package:ai_partner/presentation/widgets/wifi_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SavedScanCard extends StatelessWidget {
  final VisionResult scan;
  const SavedScanCard({super.key, required this.scan});

  ScanFlags get _flags =>
      ScanFlags.from(content: scan.content, type: scan.type);

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _snack(BuildContext context, String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final flags = _flags;

    return Dismissible(
      key: Key('dismiss_${scan.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final confirmed = await _showDeleteConfirm(context, l10n);
        if (confirmed) {
          context
              .read<HapticService>()
              .triggerSuccess(); 
        }
        return confirmed;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
      ),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.dividerColor),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showDetail(context, l10n),
          onLongPress: () {
            context.read<HapticService>().triggerLoading();
            _showEditDialog(context, scan, l10n);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    flags.icon,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scan.label ?? "Untitled",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        scan.content.replaceAll('\n', ' '),
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        context.read<HapticService>().trigger();
                        context.read<SavedScanCubit>().toggleFavorite(scan.id);
                      },
                      icon: Icon(
                        scan.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: scan.isFavorite ? Colors.redAccent : Colors.grey,
                        size: 22,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scroll) => SingleChildScrollView(
          controller: scroll,
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
                scan.label?.toUpperCase() ?? "CONTENT",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              SelectableText(
                scan.content,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 24),
              _buildActionRow(context, sheetCtx, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow(
    BuildContext context,
    BuildContext sheetCtx,
    AppLocalizations l10n,
  ) {
    final flags = _flags;
    void pop() => Navigator.pop(sheetCtx);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ActionButton(
          icon: Icons.edit_rounded,
          onTap: () {
            context.read<SoundService>().playTap();
            context.read<HapticService>().trigger();
            pop();
            _showEditDialog(context, scan, l10n);
          },
        ),
        ActionButton(
          icon: Icons.copy_rounded,
          onTap: () {
            Clipboard.setData(ClipboardData(text: scan.content));
            context.read<HapticService>().trigger();
            pop();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.copiedLabel)));
          },
        ),
        ActionButton(
          icon: Icons.share_rounded,
          onTap: () => Share.share(scan.content),
        ),
        if (flags.isWifi)
          ActionButton(
            icon: Icons.wifi_password,
            onTap: () {
              pop();
              showWifiDialog(
                context,
                scan.content,
                onNotify: (msg) => _snack(context, msg),
              );
            },
          ),
        if (flags.isUrl)
          ActionButton(
            icon: Icons.open_in_browser_rounded,
            onTap: () => _launch(scan.content),
          ),
        if (flags.isPhone)
          ActionButton(
            icon: Icons.call_rounded,
            onTap: () =>
                _launch("tel:${scan.content.replaceAll(RegExp(r'\s+'), '')}"),
          ),
        if (flags.isEmail)
          ActionButton(
            icon: Icons.email_outlined,
            onTap: () => _launch("mailto:${scan.content.trim()}"),
          ),
        if (flags.canTts)
          ActionButton(
            icon: Icons.record_voice_over_rounded,
            onTap: () {
              context.read<SoundService>().playTap();
              context.read<HapticService>().trigger();
              pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TtsPlayerPage(text: scan.content),
                ),
              );
            },
          ),
        if (flags.canTranslate)
          ActionButton(
            icon: Icons.g_translate_rounded,
            onTap: () {
              context.read<SoundService>().playTap();
              context.read<HapticService>().trigger();
              pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TranslatorScreen(initialText: scan.content),
                ),
              );
            },
          ),
      ],
    );
  }

  Future<bool> _showDeleteConfirm(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
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

  void _showEditDialog(
    BuildContext context,
    VisionResult res,
    AppLocalizations l10n,
  ) {
    final labelCtrl = TextEditingController(text: res.label ?? '');
    final contentCtrl = TextEditingController(text: res.content);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Scan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.nameLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: labelCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.nameLabel,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Content',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: contentCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Scan content...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final newLabel = labelCtrl.text.trim();
              final newContent = contentCtrl.text.trim();
              if (newLabel.isNotEmpty) {
                context.read<SavedScanCubit>().updateLabel(res.id, newLabel);
              }
              if (newContent.isNotEmpty && newContent != res.content) {
                context.read<SavedScanCubit>().updateContent(
                  res.id,
                  newContent,
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

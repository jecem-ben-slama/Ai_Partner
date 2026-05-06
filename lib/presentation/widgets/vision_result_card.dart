// ignore_for_file: deprecated_member_use

import 'package:ai_partner/core/l10n/app_localizations.dart';
import 'package:ai_partner/logic/cubit/saved_scan/saved_scan_cubit.dart';
import 'package:ai_partner/logic/cubit/saved_scan/saved_scan_state.dart';
import 'package:ai_partner/logic/services/haptic_service.dart';
import 'package:ai_partner/models/scan_result_model.dart';
import 'package:ai_partner/presentation/widgets/action_button.dart';
import 'package:ai_partner/presentation/widgets/scan_content_utils.dart';
import 'package:ai_partner/presentation/widgets/wifi_services.dart';
import 'package:ai_partner/presentation/screens/translator_screen.dart';
import 'package:ai_partner/presentation/screens/tts_player_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class VisionResultCard extends StatefulWidget {
  final VisionResult result;
  const VisionResultCard({super.key, required this.result});

  @override
  State<VisionResultCard> createState() => _VisionResultCardState();
}

class _VisionResultCardState extends State<VisionResultCard> {
  bool _isEditing = false;

  // ─────────────────────────────
  // TEXT SOURCE OF TRUTH
  // ─────────────────────────────
  String get text => widget.result.content.trim();

  late TextEditingController _editController;

  // ─────────────────────────────
  // NORMALIZED TEXT (IMPORTANT FOR OCR WIFI)
  // ─────────────────────────────
  String get normalizedText {
    return text.replaceAll('\n', '').replaceAll(' ', '').toLowerCase();
  }

  ScanFlags get flags =>
      ScanFlags.from(content: normalizedText, type: widget.result.type);

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.result.content);
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  // ─────────────────────────────
  // URL LAUNCHER
  // ─────────────────────────────
  Future<void> _launch(String value) async {
    final uri = Uri.parse(value);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ─────────────────────────────
  // NOTIFICATION
  // ─────────────────────────────
  void _notify(String message) {
    final overlay = Overlay.of(context);

    final entry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: MediaQuery.of(ctx).padding.top + 10,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF161925),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(message, style: const TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), entry.remove);
  }

  // ─────────────────────────────
  // SAVE DIALOG
  // ─────────────────────────────
  void _showSaveDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final nameController = TextEditingController(
      text: widget.result.label ?? widget.result.type.name.toUpperCase(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.saveitemLabel),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.nameLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();

              if (name.isNotEmpty) {
                context.read<SavedScanCubit>().saveNewScan([
                  widget.result.copyWith(
                    label: name,
                    content: _isEditing
                        ? _editController.text
                        : widget.result.content,
                  ),
                ], errorMessage: l10n.saveError);

                context.read<HapticService>().trigger();
                Navigator.pop(ctx);
              }
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────
  // UI
  // ─────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final isSaved =
        context.watch<SavedScanCubit>().state is SavedScanLoaded &&
        (context.read<SavedScanCubit>().state as SavedScanLoaded).savedScans
            .any((s) => s.id == widget.result.id);

    final currentText = _isEditing ? _editController.text.trim() : text;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      child: ExpansionTile(
        leading: Icon(flags.icon),
        title: Text(widget.result.label ?? "Result"),
        subtitle: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),

        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ───────── TEXT / EDIT ─────────
                _isEditing
                    ? TextField(
                        controller: _editController,
                        maxLines: null,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      )
                    : SelectableText(currentText),

                const Divider(),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ActionButton(
                        icon: Icons.edit,
                        onTap: () => setState(() {
                          _isEditing = !_isEditing;
                        }),
                      ),

                      ActionButton(
                        icon: Icons.copy,
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: currentText));
                          _notify(l10n.copiedLabel);
                        },
                      ),

                      ActionButton(
                        icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                        onTap: () => _showSaveDialog(context),
                      ),

                      ActionButton(
                        icon: Icons.share,
                        onTap: () => Share.share(currentText),
                      ),

                      // ───────── WIFI ─────────
                      if (flags.isWifi)
                        ActionButton(
                          icon: Icons.wifi,
                          onTap: () => showWifiDialog(
                            context,
                            currentText,
                            onNotify: _notify,
                          ),
                        ),

                      // ───────── URL ─────────
                      if (flags.isUrl)
                        ActionButton(
                          icon: Icons.open_in_browser,
                          onTap: () => _launch(currentText),
                        ),

                      // ───────── PHONE ─────────
                      if (flags.isPhone)
                        ActionButton(
                          icon: Icons.call,
                          onTap: () => _launch(
                            "tel:${currentText.replaceAll(RegExp(r'[\s\-\(\)]'), '')}",
                          ),
                        ),

                      // ───────── EMAIL ─────────
                      if (flags.isEmail)
                        ActionButton(
                          icon: Icons.email_outlined,
                          onTap: () => _launch("mailto:$currentText"),
                        ),

                      // ───────── TTS ─────────
                      if (flags.canTts)
                        ActionButton(
                          icon: Icons.record_voice_over_rounded,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TtsPlayerPage(text: currentText),
                              ),
                            );
                          },
                        ),

                      // ───────── TRANSLATE ─────────
                      if (flags.canTranslate)
                        ActionButton(
                          icon: Icons.g_translate_rounded,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TranslatorScreen(initialText: currentText),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

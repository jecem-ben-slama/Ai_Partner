import 'package:ai_partner/core/l10n/app_localizations.dart';
import 'package:ai_partner/logic/cubit/saved_scan/saved_scan_cubit.dart';
import 'package:ai_partner/logic/cubit/saved_scan/saved_scan_state.dart';
import 'package:ai_partner/logic/services/haptic_service.dart';
import 'package:ai_partner/logic/services/sound_service.dart';
import 'package:ai_partner/models/scan_result_model.dart';
import 'package:ai_partner/presentation/screens/translator_screen.dart';
import 'package:ai_partner/presentation/screens/tts_player_page.dart';
import 'package:ai_partner/presentation/widgets/action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class VisionResultCard extends StatelessWidget {
  final VisionResult result;
  const VisionResultCard({super.key, required this.result});

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

  //! to be reused for rename dialog
  void _showSaveDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final TextEditingController nameController = TextEditingController(
      text: result.label ?? result.type.name.toUpperCase(),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          l10n.saveitemLabel,
          style: TextStyle(
            color: Theme.of(context).colorScheme.brightness == Brightness.light
                ? Colors.black
                : Colors.white,
          ),
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(labelText: l10n.nameLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n.cancel,
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
              final String customName = nameController.text.trim();
              if (customName.isNotEmpty) {
                final updatedResult = result.copyWith(label: customName);
                context.read<SavedScanCubit>().saveNewScan([
                  updatedResult,
                ], errorMessage: l10n.saveError);
                context.read<HapticService>().trigger;

                Navigator.pop(dialogContext);
              }
            },
            child: Text(
              l10n.confirm,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isPhone =
        result.type == VisionType.phone || _isProbablyPhone(result.content);
    final bool isUrl = result.type == VisionType.url;
    final bool canTranslate =
        result.type == VisionType.text ||
        result.type == VisionType.barcode ||
        result.type == VisionType.qr;

    return BlocBuilder<SavedScanCubit, SavedScanState>(
      builder: (context, state) {
        // 1. Check if this specific result ID is in the saved history
        bool isSaved = false;
        if (state is SavedScanLoaded) {
          isSaved = state.savedScans.any((scan) => scan['id'] == result.id);
        }

        return Card(
          color: Theme.of(context).colorScheme.surface,
          margin: const EdgeInsets.only(bottom: 12),
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            iconColor: Theme.of(context).colorScheme.onSurface,
            collapsedIconColor: Theme.of(context).colorScheme.onSurface,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIcon(isPhone),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              result.label ?? "Result",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              result.content,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 13,
              ),
            ),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      result.content,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const Divider(height: 24, color: Colors.white10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ActionButton(
                            icon: Icons.copy,
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: result.content),
                              );
                              context.read<HapticService>().trigger;

                              _showTopNotification(context, l10n.copiedLabel);
                            },
                          ),

                          // 2. TOGGLE SAVE BUTTON: UI reacts to isSaved
                          ActionButton(
                            icon: isSaved
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            iconColor: isSaved
                                ? Theme.of(context).colorScheme.primary
                                : null,
                            onTap: () {
                              if (isSaved) {
                                // Unsave logic
                                context.read<SavedScanCubit>().deleteItem(
                                  result.id,
                                  errorMessage: l10n.deleteError,
                                );
                                context.read<HapticService>().trigger;
                                context.read<SoundService>().playTap();
                              } else {
                                // Save logic
                                _showSaveDialog(context);
                              }
                            },
                          ),

                          ActionButton(
                            icon: Icons.share_outlined,
                            // ignore: deprecated_member_use
                            onTap: () => Share.share(result.content),
                          ),

                          if (result.type == VisionType.text)
                            ActionButton(
                              icon: Icons.record_voice_over_rounded,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TtsPlayerPage(text: result.content),
                                ),
                              ),
                            ),

                          if (canTranslate)
                            ActionButton(
                              icon: Icons.g_translate_rounded,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (c) => TranslatorScreen(
                                    initialText: result.content,
                                  ),
                                ),
                              ),
                            ),

                          if (isPhone)
                            ActionButton(
                              icon: Icons.call,
                              onTap: () => _launch(
                                "tel:${result.content.replaceAll(RegExp(r'[\s\-\(\)]'), '')}",
                              ),
                            ),

                          if (isUrl)
                            ActionButton(
                              icon: Icons.open_in_browser,
                              onTap: () => _launch(result.content),
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
      },
    );
  }

  IconData _getIcon(bool isPhone) {
    if (isPhone) return Icons.phone;
    switch (result.type) {
      case VisionType.url:
        return Icons.language;
      case VisionType.barcode:
        return Icons.qr_code_2;
      case VisionType.qr:
        return Icons.qr_code;
      case VisionType.text:
      default:
        return Icons.text_fields;
    }
  }
}

import 'package:ai_partner/logic/cubit/storage/history_cubit.dart';
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

  /// Shows a dialog to name the item before saving
  void _showSaveDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController(
      // Default name based on the type
      text: result.label ?? result.type.name.toUpperCase(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Save Item"),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: "Item Name",
            hintText: "e.g. My Phone Number, Work Link...",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final String customName = nameController.text.trim();
              if (customName.isNotEmpty) {
                // Create a copy of the result with the new label
                final updatedResult = result.copyWith(label: customName);

                context.read<HistoryCubit>().saveNewScan([updatedResult]);

                Navigator.pop(context);
                _showFloatingSnack(context, "Saved as '$customName'");
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isPhone =
        result.type == VisionType.phone || _isProbablyPhone(result.content);
    final bool isUrl = result.type == VisionType.url;
    final bool canTranslate =
        result.type == VisionType.text ||
        result.type == VisionType.barcode ||
        result.type == VisionType.qr;

    return Card(
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        iconColor: Theme.of(context).colorScheme.onSurface,
        collapsedIconColor: Theme.of(context).colorScheme.onSurface,
        expansionAnimationStyle: const AnimationStyle(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeIn,
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white70,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          _showFloatingSnack(context, "Copied!");
                        },
                      ),

                      // UPDATED SAVE BUTTON
                      ActionButton(
                        icon: Icons.bookmark_border,
                        onTap: () => _showSaveDialog(context),
                      ),

                      ActionButton(
                        icon: Icons.share_outlined,
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
                              builder: (c) =>
                                  TranslatorScreen(initialText: result.content),
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
}

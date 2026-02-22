import 'package:ai_partner/logic/cubit/storage/history_cubit.dart';
import 'package:ai_partner/models/scan_result_model.dart';
import 'package:ai_partner/presentation/screens/translator_screen.dart';
import 'package:ai_partner/presentation/widgets/action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class VisionResultCard extends StatelessWidget {
  final VisionResult result;
  const VisionResultCard({super.key, required this.result});

  // Helper to detect phone numbers in plain text scans
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

  @override
  Widget build(BuildContext context) {
    final bool showCallAction =
        result.type == VisionType.phone || _isProbablyPhone(result.content);

    return Card(
      color: const Color(0xFF364156),
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        collapsedIconColor: Colors.white70,
        iconColor: Theme.of(context).colorScheme.primary,
        leading: Icon(
          _getIcon(showCallAction),
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          result.label ?? "Result",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          result.content,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.black12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  result.content,
                  style: const TextStyle(
                    color: Colors.white,
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
                        label: "Copy",
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: result.content),
                          );
                          _showFloatingSnack(context, "Copied!");
                        },
                      ),
                      ActionButton(
                        icon: Icons.bookmark_border,
                        label: "Save",
                        onTap: () {
                          context.read<HistoryCubit>().saveNewScan([result]);
                          _showFloatingSnack(context, "Saved!");
                        },
                      ),
                      ActionButton(
                        icon: Icons.share_outlined,
                        label: "Share",
                        onTap: () => Share.share(result.content),
                      ),

                      // CALL BUTTON LOGIC
                      if (showCallAction)
                        ActionButton(
                          icon: Icons.call,
                          label: "Call",
                          onTap: () => _launch(
                            "tel:${result.content.replaceAll(RegExp(r'[\s\-\(\)]'), '')}",
                          ),
                        ),

                      if (result.type == VisionType.url)
                        ActionButton(
                          icon: Icons.open_in_browser,
                          label: "Open",
                          onTap: () => _launch(result.content),
                        ),

                      if (result.type == VisionType.text ||
                          result.type == VisionType.barcode ||
                          result.type == VisionType.qr)
                        ActionButton(
                          icon: Icons.g_translate_rounded,
                          label: "Translate",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) => TranslatorScreen(
                                  initialText: result.content,
                                ),
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

  IconData _getIcon(bool isPhone) {
    if (isPhone) return Icons.phone; // Prioritize phone icon if detected
    switch (result.type) {
      case VisionType.text:
        return Icons.text_fields;
      case VisionType.url:
        return Icons.language;
      case VisionType.phone:
        return Icons.phone;
      case VisionType.barcode:
        return Icons.qr_code_2;
      case VisionType.qr:
        return Icons.qr_code;
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

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

  @override
  Widget build(BuildContext context) {
    final bool showCallAction =
        result.type == VisionType.phone || _isProbablyPhone(result.content);

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
          reverseCurve: Curves.easeIn,
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getIcon(showCallAction),
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
                      // TTS BUTTON
                      // Inside VisionResultCard Row children:
                      ActionButton(
                        icon: Icons.record_voice_over_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TtsPlayerPage(text: result.content),
                            ),
                          );
                        },
                      ),
                      ActionButton(
                        icon: Icons.copy,
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: result.content),
                          );
                          _showFloatingSnack(context, "Copied!");
                        },
                      ),
                      ActionButton(
                        icon: Icons.bookmark_border,
                        onTap: () {
                          context.read<HistoryCubit>().saveNewScan([result]);
                          _showFloatingSnack(context, "Saved!");
                        },
                      ),
                      ActionButton(
                        icon: Icons.share_outlined,
                        // ignore: deprecated_member_use
                        onTap: () => Share.share(result.content),
                      ),
                      if (showCallAction)
                        ActionButton(
                          icon: Icons.call,
                          onTap: () => _launch(
                            "tel:${result.content.replaceAll(RegExp(r'[\s\-\(\)]'), '')}",
                          ),
                        ),
                      if (result.type == VisionType.url)
                        ActionButton(
                          icon: Icons.open_in_browser,
                          onTap: () => _launch(result.content),
                        ),
                      if (result.type == VisionType.text ||
                          result.type == VisionType.barcode ||
                          result.type == VisionType.qr)
                        ActionButton(
                          icon: Icons.g_translate_rounded,
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
    if (isPhone) return Icons.phone;
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

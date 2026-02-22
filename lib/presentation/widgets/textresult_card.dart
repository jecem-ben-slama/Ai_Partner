import 'package:ai_partner/logic/cubit/storage/history_cubit.dart';
import 'package:ai_partner/presentation/screens/translator_screen.dart';
import 'package:ai_partner/presentation/widgets/action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TextResultCard extends StatelessWidget {
  final String text;
  const TextResultCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF364156), // Matching your Barcode Card color
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The Text Area
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SelectableText(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.white,
              ),
            ),
          ),

          // The Action Divider
          const Divider(height: 1, color: Colors.white10),

          // The Action Bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ActionButton(
                  icon: Icons.bookmark_add_outlined,
                  label: "Save",
                  onTap: () {
                    // Save just the text block
                    context.read<HistoryCubit>().saveNewScan(text, []);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Text saved to history!")),
                    );
                  },
                ),
                ActionButton(
                  icon: Icons.g_translate_rounded,
                  label: "Translate",
                  onTap: () {
                    // 1. Close the bottom sheet first
                    //Navigator.pop(sheetContext);

                    // 2. Navigate to the Translator Screen with the text
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TranslatorScreen(
                          initialText: text ,
                        ),
                      ),
                    );
                  },
                ),
                ActionButton(
                  icon: Icons.copy,
                  label: "Copy",
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Text copied!")),
                    );
                  },
                ),
                // Extra AI Tip: You could add a "Share" button here too!
                ActionButton(
                  icon: Icons.share_outlined,
                  label: "Share",
                  onTap: () {
                    // Add share logic later
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:ai_partner/l10n/app_localizations.dart';
import 'package:ai_partner/presentation/screens/translator_screen.dart';
import 'package:ai_partner/presentation/screens/tts_player_page.dart';
import 'package:ai_partner/presentation/screens/vision_scanner_screen.dart';
import 'package:ai_partner/presentation/widgets/at_tool_selection_widget.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Center(
        child: Column(
          children: [
            const Text(
              "Welcome to AI Partner!\nUse the bottom navigation to explore features.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: MediaQuery.sizeOf(context).width * 0.2),
            AiToolSelection(
              label: l10n.textExtraction,
              page: VisionScannerScreen(),
            ),
            SizedBox(height: MediaQuery.sizeOf(context).width * 0.2),
            AiToolSelection(
              label: l10n.textTranslation,
              page: TranslatorScreen(),
            ),
            SizedBox(height: MediaQuery.sizeOf(context).width * 0.2),
            AiToolSelection(label: "tts", page: TtsPlayerPage( ))
          ],
        ),
      ),
    );
  }
}

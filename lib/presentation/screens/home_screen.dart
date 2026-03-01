import 'package:ai_partner/core/theme/app_colors.dart';
import 'package:ai_partner/l10n/app_localizations.dart';
import 'package:ai_partner/presentation/screens/translator_screen.dart';
import 'package:ai_partner/presentation/screens/tts_player_page.dart';
import 'package:ai_partner/presentation/screens/vision_scanner_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. Sleek Modern AppBar/Header
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),

              background: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: 40,
                    child: Icon(
                      Icons.auto_awesome,
                      size: 150,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Content Section
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  l10n.welcomeText,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),

                // 3. High-End Tool Cards
                _buildToolCard(
                  context,
                  label: l10n.textExtraction,
                  icon: Icons.camera_enhance_rounded,
                  color: Colors.orangeAccent,
                  page: const VisionScannerScreen(),
                ),
                _buildToolCard(
                  context,
                  label: l10n.textTranslation,
                  icon: Icons.translate_rounded,
                  color: Colors.blueAccent,
                  page: const TranslatorScreen(),
                ),
                _buildToolCard(
                  context,
                  label: l10n.ttsLabel,
                  icon: Icons.record_voice_over_rounded,
                  color: Colors.purpleAccent,
                  page: const TtsPlayerPage(),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required Widget page,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon Container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(width: 20),
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

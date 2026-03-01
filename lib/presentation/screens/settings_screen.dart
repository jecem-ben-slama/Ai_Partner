import 'package:ai_partner/l10n/app_localizations.dart';
import 'package:ai_partner/logic/cubit/settings/settings_cubit.dart';
import 'package:ai_partner/logic/cubit/settings/settings_state.dart';
import 'package:ai_partner/presentation/widgets/language_selector_tile.dart';
import 'package:ai_partner/presentation/widgets/settings_switch_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Appearance"),

                //                _buildSectionHeader(l10n.appearanceLabel ?? "Appearance"),
                _buildSettingsGroup([
                  SettingsSwitchWidget(
                    title: l10n.darkMode,
                    icon: Icons.dark_mode_rounded,
                    trailing: Switch.adaptive(
                      activeColor: Colors.blueAccent,
                      value: state.themeMode == ThemeMode.dark,
                      onChanged: (value) =>
                          context.read<SettingsCubit>().toggleTheme(),
                    ),
                  ),
                  LanguageSelectorTile(
                    title: l10n.language,
                    currentLanguageCode: state.locale.languageCode,
                  ),
                ]),
                const SizedBox(height: 25),
                //  _buildSectionHeader(l10n.systemLabel ?? "System"),
                _buildSectionHeader("System"),

                _buildSettingsGroup([
                  SettingsSwitchWidget(
                    title: l10n.resetTitle,
                    icon: Icons.restart_alt_rounded,
                    onTap: () => showResetDialog(context, l10n),
                  ),
                  SettingsSwitchWidget(
                    title: l10n.aboutLabel,
                    icon: Icons.info_outline_rounded,
                    onTap: () => _showAboutSheet(context, l10n),
                  ),
                ]),
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    "v1.2.4",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05), // Subtle for dark mode
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Column(
          children: children.asMap().entries.map((entry) {
            final index = entry.key;
            final widget = entry.value;
            return Column(
              children: [
                widget,
                if (index != children.length - 1)
                  Divider(
                    indent: 60,
                    endIndent: 20,
                    height: 1,
                    color: Colors.grey.withValues(alpha: 0.1),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAboutSheet(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        maxChildSize: 0.6,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 25),
              const Icon(
                Icons.auto_awesome,
                size: 50,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 15),
              Text(
                l10n.appTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Your intelligent companion for vision, translation, and speech.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {}, // Add URL Launcher logic
                icon: const Icon(Icons.code_rounded),
                label: const Text("View on GitHub"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showResetDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
            const SizedBox(width: 12),
            Text(l10n.resetTitle),
          ],
        ),
        content: Text(l10n.resetWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
              foregroundColor: Colors.redAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              context.read<SettingsCubit>().resetSettings();
              Navigator.pop(context);
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }
}

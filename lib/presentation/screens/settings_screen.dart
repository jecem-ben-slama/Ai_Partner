import 'package:ai_partner/l10n/app_localizations.dart';
import 'package:ai_partner/logic/cubit/settings/settings_cubit.dart';
import 'package:ai_partner/logic/cubit/settings/settings_state.dart';
import 'package:ai_partner/logic/services/haptic_service.dart';
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
                // --- Appearance ---
                _buildSectionHeader(l10n.appearanceLabel),
                _buildSettingsGroup([
                  SettingsSwitchWidget(
                    title: l10n.darkMode,
                    icon: Icons.dark_mode_rounded,
                    trailing: Switch.adaptive(
                      activeThumbColor: Colors.blueAccent,
                      value: state.themeMode == ThemeMode.dark,
                      onChanged: (value) {
                        context.read<SettingsCubit>().toggleTheme();
                        context.read<HapticService>().trigger();
                      },
                    ),
                  ),
                  LanguageSelectorTile(
                    title: l10n.language,
                    currentLanguageCode: state.locale.languageCode,
                  ),
                ]),

                const SizedBox(height: 25),

                // --- Interaction ---
                _buildSectionHeader(l10n.interactionLabel),
                _buildSettingsGroup([
                  // Haptic Selection Tile (Matches LanguageSelectorTile style)
                  SettingsSwitchWidget(
                    title: l10n.hapticLabel,
                    icon: Icons.vibration_rounded,
                    onTap: () => _showHapticSelector(context, state, l10n),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getHapticName(state.hapticLevel, l10n),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ]),

                const SizedBox(height: 25),

                // --- System ---
                _buildSectionHeader(l10n.systemLabel),
                _buildSettingsGroup([
                  SettingsSwitchWidget(
                    title: l10n.resetTitle,
                    icon: Icons.restart_alt_rounded,
                    onTap: () {
                      context.read<HapticService>().trigger();

                      showResetDialog(context, l10n);
                    },
                  ),
                  SettingsSwitchWidget(
                    title: l10n.aboutLabel,
                    icon: Icons.info_outline_rounded,
                    onTap: () => _showAboutSheet(context, l10n),
                  ),
                ]),

                const SizedBox(height: 40),
                const Center(
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

  // Helper to map Enum to Translated String
  String _getHapticName(HapticIntensity level, AppLocalizations l10n) {
    switch (level) {
      case HapticIntensity.off:
        return l10n.off;
      case HapticIntensity.light:
        return l10n.low;
      case HapticIntensity.medium:
        return l10n.med;
      case HapticIntensity.strong:
        return l10n.high;
    }
  }

  // Opens a selection list dialog similar to Language selection
  void _showHapticSelector(
    BuildContext context,
    SettingsState state,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.hapticLabel),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: RadioGroup<HapticIntensity>(
          groupValue: state.hapticLevel,
          onChanged: (HapticIntensity? value) {
            if (value != null) {
              context.read<SettingsCubit>().setHapticLevel(value);
              context.read<HapticService>().trigger();
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: HapticIntensity.values.map((level) {
              return RadioListTile<HapticIntensity>(
                title: Text(_getHapticName(level, l10n)),
                value: level,
                activeColor: Colors.blueAccent,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // --- UI Builders (Keep your existing _buildSectionHeader and _buildSettingsGroup) ---
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
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.transparent,
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
                  color: Colors.grey,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ... Keep your _showAboutSheet and showResetDialog methods

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
                  color: Colors.grey,
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
                onPressed: () {},
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
        title: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.orangeAccent,
          size: 25,
        ),
        content: Text(l10n.resetWarning),
        actions: [
          TextButton(
            onPressed: () {
              context.read<HapticService>().trigger;
              Navigator.pop(context);
            },
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.redAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              context.read<HapticService>().trigger;
              context.read<SettingsCubit>().resetSettings();
              Navigator.pop(context);
            },
            child: Text(l10n.confirm, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

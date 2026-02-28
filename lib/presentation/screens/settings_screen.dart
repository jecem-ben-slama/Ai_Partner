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
      appBar: AppBar(title: Text(l10n.appTitle), centerTitle: true),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //* Theme Toggle
                SettingsSwitchWidget(
                  title: l10n.darkMode,
                  icon: Icons.dark_mode,
                  trailing: Transform.scale(
                    scale: 0.9,
                    child: Switch(
                      padding: EdgeInsets.all(20),
                      thumbColor: WidgetStateProperty.resolveWith<Color?>((
                        states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return Colors.white; // Blue when ON
                        }
                        return Colors.black; // White when OFF
                      }),
                      value: state.themeMode == ThemeMode.dark,
                      onChanged: (value) =>
                          context.read<SettingsCubit>().toggleTheme(),
                    ),
                  ),
                ),
                const Divider(),
                //* Language Selector
                LanguageSelectorTile(
                  title: l10n.language,
                  currentLanguageCode: state.locale.languageCode,
                ),
                const Divider(),
                //* Reset Settings
                SettingsSwitchWidget(
                  title: l10n.resetTitle,
                  icon: Icons.restore,
                  onTap: () => showResetDialog(context, l10n),
                ),
                Divider(),
                //* About Section
                //! may add a buttom sheet with more info and links to github, etc
                SettingsSwitchWidget(
                  title: l10n.aboutLabel,
                  icon: Icons.info,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Container(
                        padding: const EdgeInsets.all(16.0),
                        width: double.infinity,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: .max,
                            children: [
                              Text(
                                l10n.appTitle,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text("test", textAlign: TextAlign.center),
                              SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Open GitHub or website
                                },
                                icon: Icon(Icons.link),
                                label: Text(l10n.resetTitle),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void showResetDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text(l10n.resetTitle),
          ],
        ),
        content: Text(l10n.resetWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<SettingsCubit>().resetSettings();
              Navigator.pop(context);
            },
            child: Text(l10n.confirm, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

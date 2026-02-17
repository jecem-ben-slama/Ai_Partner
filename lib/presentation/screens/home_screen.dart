import 'package:ai_partner/l10n/app_localizations.dart';
import 'package:ai_partner/logic/settings/settings_cubit.dart';
import 'package:ai_partner/logic/settings/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Get the localizations object for current context
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        // Uses the localized title from your .arb files
        title: Text(l10n.appTitle),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section: Theme Testing
                ListTile(
                  title: Text(l10n.darkMode),
                  trailing: Switch(
                    value: state.themeMode == ThemeMode.dark,
                    onChanged: (value) =>
                        context.read<SettingsCubit>().toggleTheme(),
                  ),
                ),
                const Divider(),

                // Section: Language Testing
                ListTile(
                  title: Text(l10n.language),
                  trailing: DropdownButton<String>(
                    value: state.locale.languageCode,
                    items: const [
                      DropdownMenuItem(value: 'fr', child: Text("Français")),
                      DropdownMenuItem(value: 'en', child: Text("English")),
                      DropdownMenuItem(value: 'ar', child: Text("العربية")),
                    ],
                    onChanged: (String? code) {
                      if (code != null) {
                        context.read<SettingsCubit>().changeLanguage(code);
                      }
                    },
                  ),
                ),

                const Spacer(),
                // Displaying current state for debugging
                Center(
                  child: Text(
                    "Current: ${state.locale.languageCode.toUpperCase()} | ${state.themeMode.name.toUpperCase()}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

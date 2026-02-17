import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'l10n/app_localizations.dart';
import 'logic/settings/settings_cubit.dart';
import 'logic/settings/settings_state.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Place the BlocProvider at the very top
    return BlocProvider(
      create: (context) => SettingsCubit(),
      // 2. Use a child widget (or a Builder) so the context contains the Cubit
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    // Now this context is UNDER the BlocProvider and can find the Cubit
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: state.locale,
          themeMode: state.themeMode,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeScreen(),
        );
      },
    );
  }
}

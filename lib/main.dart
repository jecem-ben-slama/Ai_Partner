import 'package:ai_partner/core/theme/app_colors.dart';
import 'package:ai_partner/logic/ml/text_recognaizer_service.dart';
import 'package:ai_partner/logic/text/text_cubit.dart';
import 'package:ai_partner/presentation/screens/navbar_screen.dart';
import 'package:ai_partner/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

//* Localization imports
import 'package:ai_partner/l10n/app_localizations.dart';

//* Logic & UI imports
import 'logic/settings/settings_cubit.dart';
import 'logic/settings/settings_state.dart';

void main() async {
  // 1. Ensure Flutter bindings are initialized for async code
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load SharedPreferences before the app starts
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    // 3. Pass the pre-loaded prefs directly to your Cubit
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SettingsCubit(prefs)),
        BlocProvider(create: (context) => TextCubit(TextRecognizerService())),
      ],
      child: SafeArea(child: const AppView()),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          //* Theme Management
          themeMode: state.themeMode,
          //? Light Theme
          theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
          //? Dark Theme
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,

            scaffoldBackgroundColor: AppColors.backgroundDark,
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              secondary: AppColors.secondary,
              surface: AppColors.surfaceDark,
              onSurface: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.backgroundDark,
              elevation: 0,
              centerTitle: true,
            ),
          ),

          //* Localization Management
          locale: state.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          //* Index
          home: state.showOnboarding
              ? const OnboardingScreen()
              : const NavbarScreen(),
        );
      },
    );
  }
}

//* Package imports
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
//* Localization imports
import 'package:ai_partner/l10n/app_localizations.dart';
//* Service imports
import 'package:ai_partner/logic/services/universal_scanner_service.dart';
import 'package:ai_partner/logic/services/settings_service.dart';
import 'package:ai_partner/logic/services/storage_service.dart';
import 'package:ai_partner/logic/services/tts_service.dart'; 
//* Themes & UI imports
import 'package:ai_partner/core/theme/app_colors.dart';
import 'package:ai_partner/presentation/screens/navbar_screen.dart';
import 'package:ai_partner/presentation/screens/onboarding_screen.dart';
//* Cubit imports
import 'package:ai_partner/logic/cubit/translation/translation_cubit.dart';
import 'package:ai_partner/logic/cubit/storage/history_cubit.dart';
import 'package:ai_partner/logic/cubit/scanning/vision_cubit.dart';
import 'package:ai_partner/logic/cubit/tts/tts_cubit.dart';
import 'logic/cubit/settings/settings_cubit.dart';
import 'logic/cubit/settings/settings_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final settingsService = SettingsService(prefs);
  final ttsService = TtsService();
  runApp(
    MyApp(
      prefs: prefs,
      settingsService: settingsService,
      ttsService: ttsService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final SettingsService settingsService;
  final TtsService ttsService;
  const MyApp({
    super.key,
    required this.prefs,
    required this.settingsService,
    required this.ttsService, 
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SettingsCubit(settingsService)),
        BlocProvider(
          create: (context) => VisionCubit(UniversalScannerService()),
        ),
        BlocProvider(
          create: (context) => HistoryCubit(StorageService())..loadHistory(),
        ),
        BlocProvider(create: (context) => TranslationCubit()),
        BlocProvider(create: (context) => TtsCubit(ttsService)),
      ],
      child: SafeArea(
        child: const AppView(),
        ),    );
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
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: AppColors.backgroundLight,
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryLight,
              onPrimary: AppColors.onPrimaryLight,
              secondary: AppColors.secondaryLight,
              surface: AppColors.surfaceLight,
              onSurface: AppColors.onSurfaceLight,
              error: AppColors.error,
              tertiary: AppColors.primaryLight,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.backgroundLight,
              elevation: 0,
              centerTitle: true,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.backgroundDark,
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryLight,
              onPrimary: AppColors.onPrimaryDark,
              secondary: AppColors.secondaryDark,
              onSecondary: AppColors.onSecondaryDark,
              surface: AppColors.surfaceDark,
              onSurface: AppColors.onSurfaceDark,
              tertiary: Color(0xFF161925),
              error: AppColors.error,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.backgroundDark,
              elevation: 0,
              centerTitle: true,
            ),
          ),
          themeMode: state.themeMode,
          locale: state.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: state.showOnboarding
              ? const OnboardingScreen()
              : const NavbarScreen(),
        );
      },
    );
  }
}

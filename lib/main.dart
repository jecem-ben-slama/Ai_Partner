import 'package:ai_partner/core/theme/app_colors.dart';
import 'package:ai_partner/logic/ml/universal_scanner_service.dart';
import 'package:ai_partner/logic/text/vision_cubit.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SettingsCubit(prefs)),
        BlocProvider(create: (context) => VisionCubit(UniversalScannerService())),
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
          //? Light Theme
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: AppColors.backgroundLight,
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryLight,
              onPrimary: AppColors.onPrimaryLight,
              secondary: AppColors.secondaryLight,
              surface: AppColors.surfaceLight,
              onSurface: AppColors.onSurfaceLight,
              error: AppColors.error,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.backgroundLight,
              elevation: 0,
              centerTitle: true,
            ),
          ),
          //? Dark Theme
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.backgroundDark,
            colorScheme: ColorScheme.dark(
              primary: AppColors.primaryDark,
              onPrimary: AppColors.onPrimaryDark,
              secondary: AppColors.secondaryDark,
              onSecondary: AppColors.onSecondaryDark,
              surface: AppColors.surfaceDark,
              onSurface: AppColors.onSurfaceDark,
              error: AppColors.error,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.backgroundDark,
              elevation: 0,
              centerTitle: true,
            ),
          ),
          themeMode: state.themeMode,

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

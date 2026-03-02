//* Package imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

//* Service imports
import 'package:ai_partner/logic/services/haptic_service.dart';
import 'package:ai_partner/logic/services/universal_scanner_service.dart';
import 'package:ai_partner/logic/services/settings_service.dart';
import 'package:ai_partner/logic/services/storage_service.dart';
import 'package:ai_partner/logic/services/tts_service.dart';

//* Cubit imports
import 'package:ai_partner/logic/cubit/translation/translation_cubit.dart';
import 'package:ai_partner/logic/cubit/storage/history_cubit.dart';
import 'package:ai_partner/logic/cubit/scanning/vision_cubit.dart';
import 'package:ai_partner/logic/cubit/tts/tts_cubit.dart';
import 'package:ai_partner/logic/cubit/settings/settings_cubit.dart';
import 'package:ai_partner/logic/cubit/settings/settings_state.dart';

//* Core & UI imports
import 'package:ai_partner/core/theme/app_theme.dart';
import 'package:ai_partner/l10n/app_localizations.dart';
import 'package:ai_partner/presentation/screens/navbar_screen.dart';
import 'package:ai_partner/presentation/screens/onboarding_screen.dart';

void main() async {
  // Ensure native bindings are ready
  WidgetsFlutterBinding.ensureInitialized();
await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Initialize SharedPreferences
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Initialize Core Services
  final settingsService = SettingsService(prefs);
  final ttsService = TtsService();
  final hapticService = HapticService();

  // Pre-sync HapticService with saved user preference
  hapticService.updateSetting(settingsService.hapticLevel);
  runApp(
    MyApp(
      settingsService: settingsService,
      ttsService: ttsService,
      hapticService: hapticService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final SettingsService settingsService;
  final TtsService ttsService;
  final HapticService hapticService;

  const MyApp({
    super.key,
    required this.settingsService,
    required this.ttsService,
    required this.hapticService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      // Provide stateless/action services here
      providers: [
        RepositoryProvider.value(value: hapticService),
        RepositoryProvider.value(value: ttsService),
        RepositoryProvider(create: (_) => UniversalScannerService()),
        RepositoryProvider(create: (_) => StorageService()),
      ],
      child: MultiBlocProvider(
        // Provide state-managing Cubits here
        providers: [
          BlocProvider(
            create: (context) => SettingsCubit(settingsService, hapticService),
          ),
          BlocProvider(
            create: (context) => VisionCubit(
              context.read<UniversalScannerService>(),
              hapticService,
            ),
          ),
          BlocProvider(
            create: (context) =>
                HistoryCubit(context.read<StorageService>())..loadHistory(),
          ),
          BlocProvider(create: (context) => TranslationCubit(hapticService)),
          BlocProvider(
            create: (context) =>
                TtsCubit(context.read<TtsService>(), hapticService),
          ),
        ],
        child: SafeArea(child: const AppView()),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) =>
          previous.themeMode != current.themeMode ||
          previous.locale != current.locale ||
          previous.showOnboarding != current.showOnboarding,
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
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

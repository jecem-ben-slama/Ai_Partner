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
import 'package:ai_partner/logic/services/sound_service.dart';
import 'package:ai_partner/logic/services/notification_service.dart'; // Added NotificationService import

//* Cubit imports
import 'package:ai_partner/logic/cubit/translation/translation_cubit.dart';
import 'package:ai_partner/logic/cubit/saved_scan/saved_scan_cubit.dart';
import 'package:ai_partner/logic/cubit/scanning/vision_cubit.dart';
import 'package:ai_partner/logic/cubit/tts/tts_cubit.dart';
import 'package:ai_partner/logic/cubit/settings/settings_cubit.dart';
import 'package:ai_partner/logic/cubit/settings/settings_state.dart';

//* Core & UI imports
import 'package:ai_partner/core/theme/app_theme.dart';
import 'package:ai_partner/core/l10n/app_localizations.dart';
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
    return MultiBlocProvider(
      // 1. First, provide SettingsCubit (needed by Sound and Notification services)
      providers: [
        BlocProvider(
          create: (context) => SettingsCubit(settingsService, hapticService),
        ),
      ],
      child: MultiRepositoryProvider(
        // 2. Provide Services.
        providers: [
          RepositoryProvider.value(value: hapticService),
          RepositoryProvider.value(value: ttsService),
          RepositoryProvider(
            create: (context) => SoundService(context.read<SettingsCubit>()),
          ),
          // Added NotificationService initialization
          RepositoryProvider(
            create: (context) =>
                NotificationService(context.read<SettingsCubit>())
                  ..initNotification(),
          ),
          RepositoryProvider(create: (_) => UniversalScannerService()),
          RepositoryProvider(create: (_) => StorageService()),
        ],
        child: MultiBlocProvider(
          // 3. Provide all other Cubits
          providers: [
            BlocProvider(
              create: (context) => VisionCubit(
                context.read<UniversalScannerService>(),
                hapticService,
                context.read<SoundService>(),
                context.read<NotificationService>(),
              ),
            ),
            BlocProvider(
              create: (context) => SavedScanCubit(
                context.read<StorageService>(),
                context.read<HapticService>(),
                context.read<SoundService>(),
              )..loadHistory(),
            ),
            BlocProvider(
              create: (context) => TranslationCubit(
                hapticService,
                context.read<SoundService>(),
                context.read<NotificationService>(),
              ),
            ),
            BlocProvider(
              create: (context) => TtsCubit(
                context.read<TtsService>(),
                hapticService,
                context.read<SoundService>(),
              ),
            ),
          ],
          child: const SafeArea(child: AppView()),
        ),
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

import 'package:ai_partner/logic/cubit/settings/settings_state.dart';
import 'package:ai_partner/logic/services/haptic_service.dart';
import 'package:ai_partner/logic/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsService _service;
  final HapticService _hapticService;

  SettingsCubit(this._service, this._hapticService)
    : super(
        SettingsState(
          themeMode: _service.themeMode,
          locale: _service.locale,
          showOnboarding: _service.showOnboarding,
          hapticLevel: _service.hapticLevel,
          soundEnabled: _service.soundEnabled,
          notificationsEnabled: _service.notificationsEnabled,
        ),
      );

  void toggleTheme() async {
    final newMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    await _service.setThemeMode(newMode);
    emit(state.copyWith(themeMode: newMode));
  }

  void toggleSound(bool enabled) async {
    await _service.setSoundEnabled(enabled);
    emit(state.copyWith(soundEnabled: enabled));
  }

  void toggleNotifications(bool enabled) async {
    await _service.setNotificationsEnabled(enabled);
    emit(state.copyWith(notificationsEnabled: enabled));
  }

  void completeOnboarding() async {
    await _service.setOnboardingComplete();
    emit(state.copyWith(showOnboarding: false));
  }

  void changeLanguage(String langCode) async {
    await _service.setLocale(langCode);
    emit(state.copyWith(locale: Locale(langCode)));
  }

  void setHapticLevel(HapticIntensity level) async {
    _hapticService.updateSetting(level);
    await _service.setHapticLevel(level);
    emit(state.copyWith(hapticLevel: level));
  }

  void triggerHaptic() async {
    _hapticService.trigger();
  }

  /// Reset the app by clearing preferences and deleting the SQLite database.
  void resetSettings() async {
    await _service.clearAll();

    await _service.clearDatabase();
    _hapticService.triggerSuccess();
// Inside resetSettings
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!isClosed) {
        emit(
          SettingsState(
            themeMode: ThemeMode.light, // Default to light
            locale: const Locale('en'),
            showOnboarding: true,
            hapticLevel: HapticIntensity.medium,
            soundEnabled: true,
            notificationsEnabled: true,
          ),
        );    }
  });
    // 4. Emit the factory-default state
  
  }
}

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
        ),
      );

  void toggleTheme() async {
    final newMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    await _service.setThemeMode(newMode);
    emit(state.copyWith(themeMode: newMode));
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
    // 1. Update the Service memory FIRST
    _hapticService.updateSetting(level);

    // 2. Persist to Disk
    await _service.setHapticLevel(level);

    // 3. Update UI State
    emit(state.copyWith(hapticLevel: level));
  }

  void triggerHaptic() async {
    _hapticService.trigger();
  }

  void resetSettings() async {
    await _service.clearAll();
    emit(
      SettingsState(
        themeMode: ThemeMode.light,
        locale: Locale('en'),
        showOnboarding: true,
        hapticLevel: HapticIntensity.medium,
      ),
    );
  }
}

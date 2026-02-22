import 'package:ai_partner/logic/cubit/settings/settings_state.dart';
import 'package:ai_partner/logic/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsService _service;

  SettingsCubit(this._service)
    : super(
        SettingsState(
          themeMode: _service.themeMode,
          locale: _service.locale,
          showOnboarding: _service.showOnboarding,
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

  void resetSettings() async {
    await _service.clearAll();
    emit(
      const SettingsState(
        themeMode: ThemeMode.light,
        locale: Locale('en'),
        showOnboarding: true,
      ),
    );
  }
}

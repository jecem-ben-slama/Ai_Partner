import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  static const _themeKey = 'themeMode';
  static const _langKey = 'languageCode';
  static const _onboardingKey = 'showOnboarding';

  ThemeMode get themeMode => ThemeMode.values[_prefs.getInt(_themeKey) ?? 1];
  Locale get locale => Locale(_prefs.getString(_langKey) ?? 'en');
  bool get showOnboarding => _prefs.getBool(_onboardingKey) ?? true;

  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setInt(_themeKey, mode.index);
  Future<void> setLocale(String langCode) =>
      _prefs.setString(_langKey, langCode);
  Future<void> setOnboardingComplete() => _prefs.setBool(_onboardingKey, false);

  Future<void> clearAll() => _prefs.clear();
}

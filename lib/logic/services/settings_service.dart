import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'haptic_service.dart';

class SettingsService {
  final SharedPreferences _prefs;
  SettingsService(this._prefs);

  static const _themeKey = 'themeMode';
  static const _langKey = 'languageCode';
  static const _onboardingKey = 'showOnboarding';
  static const _hapticLevelKey = 'hapticLevel';

  ThemeMode get themeMode => ThemeMode.values[_prefs.getInt(_themeKey) ?? 1];
  Locale get locale => Locale(_prefs.getString(_langKey) ?? 'en');
  bool get showOnboarding => _prefs.getBool(_onboardingKey) ?? true;

  // New: Get intensity, defaulting to medium
  HapticIntensity get hapticLevel {
    final index = _prefs.getInt(_hapticLevelKey) ?? 2; // Default to medium
    return HapticIntensity.values[index];
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setInt(_themeKey, mode.index);
  Future<void> setLocale(String langCode) =>
      _prefs.setString(_langKey, langCode);
  Future<void> setOnboardingComplete() => _prefs.setBool(_onboardingKey, false);

  // New: Save intensity
  Future<void> setHapticLevel(HapticIntensity level) =>
      _prefs.setInt(_hapticLevelKey, level.index);

  Future<void> clearAll() => _prefs.clear();
}

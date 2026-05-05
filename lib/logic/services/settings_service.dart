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
  static const _soundEnabledKey = 'soundEnabled';
  static const _notificationsEnabledKey = 'notificationsEnabled';

  ThemeMode get themeMode => ThemeMode.values[_prefs.getInt(_themeKey) ?? 1];
  Locale get locale => Locale(_prefs.getString(_langKey) ?? 'en');
  bool get showOnboarding => _prefs.getBool(_onboardingKey) ?? true;

  HapticIntensity get hapticLevel {
    final index = _prefs.getInt(_hapticLevelKey) ?? 2;
    return HapticIntensity.values[index];
  }

  bool get soundEnabled => _prefs.getBool(_soundEnabledKey) ?? true;
  bool get notificationsEnabled =>
      _prefs.getBool(_notificationsEnabledKey) ?? true;

  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setInt(_themeKey, mode.index);
  Future<void> setLocale(String langCode) =>
      _prefs.setString(_langKey, langCode);
  Future<void> setOnboardingComplete() => _prefs.setBool(_onboardingKey, false);

  Future<void> setHapticLevel(HapticIntensity level) =>
      _prefs.setInt(_hapticLevelKey, level.index);

  Future<void> setSoundEnabled(bool enabled) =>
      _prefs.setBool(_soundEnabledKey, enabled);

  Future<void> setNotificationsEnabled(bool enabled) =>
      _prefs.setBool(_notificationsEnabledKey, enabled);

  Future<void> clearAll() => _prefs.clear();
}

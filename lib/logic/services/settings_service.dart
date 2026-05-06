import 'package:ai_partner/logic/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_partner/logic/services/haptic_service.dart';

class SettingsService {
  final SharedPreferences _prefs;
final DatabaseService _dbService = DatabaseService();
  SettingsService(this._prefs);

  // --- Existing Getters ---
  ThemeMode get themeMode => ThemeMode.values[_prefs.getInt('themeMode') ?? 0];
  Locale get locale => Locale(_prefs.getString('languageCode') ?? 'en');
  bool get showOnboarding => _prefs.getBool('showOnboarding') ?? true;
  bool get soundEnabled => _prefs.getBool('soundEnabled') ?? true;
  bool get notificationsEnabled =>
      _prefs.getBool('notificationsEnabled') ?? true;
  HapticIntensity get hapticLevel =>
      HapticIntensity.values[_prefs.getInt('hapticLevel') ?? 1];

  // --- Existing Setters ---
  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setInt('themeMode', mode.index);
  Future<void> setLocale(String lang) => _prefs.setString('languageCode', lang);
  Future<void> setOnboardingComplete() =>
      _prefs.setBool('showOnboarding', false);
  Future<void> setSoundEnabled(bool val) => _prefs.setBool('soundEnabled', val);
  Future<void> setNotificationsEnabled(bool val) =>
      _prefs.setBool('notificationsEnabled', val);
  Future<void> setHapticLevel(HapticIntensity level) =>
      _prefs.setInt('hapticLevel', level.index);

  /// Clears all SharedPreferences (Theme, Language, Onboarding status)
  Future<void> clearAll() async {
    await _prefs.clear();
  }
Future<void> clearDatabase() async {
    try {
      // Use the Singleton's reset logic instead of manual file manipulation
      await _dbService.resetDatabase();
    } catch (e) {
      debugPrint("Error clearing database: $e");
    }
  }
}

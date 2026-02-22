import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final _stateSubject = BehaviorSubject<SettingsState>();
  final SharedPreferences prefs;

  SettingsCubit(this.prefs)
    : super(
        SettingsState(
          themeMode: ThemeMode.values[prefs.getInt('themeMode') ?? 1],
          locale: Locale(prefs.getString('languageCode') ?? 'en'),
          showOnboarding: prefs.getBool('showOnboarding') ?? true,
        ),
      ) {
    _stateSubject.add(state);
  }

  void toggleTheme() async {
    final newMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    await prefs.setInt('themeMode', newMode.index);
    emit(state.copyWith(themeMode: newMode));
  }

  void completeOnboarding() async {
    await prefs.setBool('showOnboarding', false);
    emit(state.copyWith(showOnboarding: false));
  }

  void changeLanguage(String langCode) async {
    await prefs.setString('languageCode', langCode);
    emit(state.copyWith(locale: Locale(langCode)));
  }

  void resetSettings() async {
    await prefs.clear();
    

    emit(
      SettingsState(
        themeMode: ThemeMode.light,
        locale: const Locale('en'),
        showOnboarding: true,
      ),
    );
  }

  @override
  Future<void> close() {
    _stateSubject.close();
    return super.close();
  }
}

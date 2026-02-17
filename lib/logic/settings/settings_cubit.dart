import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  // BehaviorSubject ensures the latest state is always broadcasted
  final _stateSubject = BehaviorSubject<SettingsState>();

  SettingsCubit() : super(const SettingsState()) {
    _stateSubject.add(state);
  }

  void toggleTheme() {
    final newMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    final newState = state.copyWith(themeMode: newMode);
    emit(newState);
    _stateSubject.add(newState);
  }

  void changeLanguage(String langCode) {
    final newState = state.copyWith(locale: Locale(langCode));
    emit(newState);
    _stateSubject.add(newState);
  }

  @override
  Future<void> close() {
    _stateSubject.close();
    return super.close();
  }
}

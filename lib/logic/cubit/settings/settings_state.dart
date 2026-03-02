import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../services/haptic_service.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final Locale locale;
  final bool showOnboarding;
  final HapticIntensity hapticLevel;

  const SettingsState({
    this.themeMode = ThemeMode.dark,
    this.locale = const Locale('en'),
    this.showOnboarding = true,
    this.hapticLevel = HapticIntensity.medium,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? showOnboarding,
    HapticIntensity? hapticLevel,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      showOnboarding: showOnboarding ?? this.showOnboarding,
      hapticLevel: hapticLevel ?? this.hapticLevel,
    );
  }

  @override
  List<Object> get props => [themeMode, locale, showOnboarding, hapticLevel];
}

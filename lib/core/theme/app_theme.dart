import 'package:flutter/material.dart';
import 'package:ai_partner/core/theme/app_colors.dart';

class AppTheme {
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryLight,
        onPrimary: AppColors.onPrimaryLight,
        secondary: AppColors.secondaryLight,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.onSurfaceLight,
        error: AppColors.error,
        tertiary: AppColors.primaryLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: AppColors.onPrimaryDark,
        secondary: AppColors.secondaryDark,
        onSecondary: AppColors.onSecondaryDark,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.onSurfaceDark,
        tertiary: Color(0xFF161925),
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}

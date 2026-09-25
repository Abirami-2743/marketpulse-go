import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Returns the correct color for the current theme (dark or light),
/// so widgets don't hardcode dark-mode-only colors from AppColors.
class ThemeColors {
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color textPrimary(BuildContext context) =>
      _isDark(context) ? AppColors.textPrimary : AppColors.lightTextPrimary;

  static Color textSecondary(BuildContext context) =>
      _isDark(context) ? AppColors.textSecondary : AppColors.lightTextSecondary;

  static Color surfaceLight(BuildContext context) =>
      _isDark(context) ? AppColors.surfaceLight : AppColors.lightSurfaceAlt;
}
import 'package:flutter/material.dart';
import 'package:daily_water_tracker/features/theme/theme_colors.dart';

ColorScheme appColorScheme(Brightness brightness) {
  if (brightness == Brightness.dark) {
    return const ColorScheme.dark(
      primary: AppPalette.brandBlue,
      onPrimary: AppPalette.white,
      secondary: AppPalette.brandBlue,
      onSecondary: AppPalette.white,
      surface: Color(0xFF121418),
      onSurface: Color(0xFFE8EDF3),
      surfaceContainerHighest: Color(0xFF2A3038),
      surfaceContainerHigh: Color(0xFF252A32),
      surfaceContainer: Color(0xFF1E2228),
      surfaceContainerLow: Color(0xFF1A1E24),
      surfaceContainerLowest: Color(0xFF161A20),
      outline: Color(0xFF4A5360),
      outlineVariant: Color(0xFF3A424D),
      error: AppPalette.cherryRed,
    );
  }

  return const ColorScheme.light(
    primary: AppPalette.brandBlue,
    onPrimary: AppPalette.white,
    secondary: AppPalette.brandBlue,
    onSecondary: AppPalette.white,
    surface: AppPalette.appBackground,
    onSurface: Color(0xFF1A1D21),
    surfaceContainerHighest: Color(0xFFE8ECF0),
    surfaceContainerHigh: Color(0xFFF4F6F8),
    surfaceContainer: AppPalette.white,
    surfaceContainerLow: Color(0xFFFAFBFC),
    surfaceContainerLowest: AppPalette.appBackground,
    outline: Color(0xFFB8C0CC),
    outlineVariant: Color(0xFFD8DEE6),
    error: AppPalette.cherryRed,
  );
}

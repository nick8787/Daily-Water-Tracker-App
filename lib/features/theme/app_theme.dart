import 'package:daily_water_tracker/common/services/localization_service.dart';
import 'package:daily_water_tracker/common/utils/system_ui_overlay.dart';
import 'package:daily_water_tracker/features/theme/color_schemes.dart';
import 'package:daily_water_tracker/features/theme/decorations.dart';
import 'package:daily_water_tracker/features/theme/ext.dart';
import 'package:daily_water_tracker/features/theme/text_styles.dart';
import 'package:daily_water_tracker/features/theme/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final ThemeData lightTheme = buildAppTheme(
  brightness: Brightness.light,
  appColors: AppColors.light,
  overlay: AppSystemUiOverlay.light,
  locale: LocalizationService.englishLocale,
);

final ThemeData darkTheme = buildAppTheme(
  brightness: Brightness.dark,
  appColors: AppColors.dark,
  overlay: AppSystemUiOverlay.dark,
  locale: LocalizationService.englishLocale,
);

ThemeData buildAppTheme({
  required Brightness brightness,
  required AppColors appColors,
  required SystemUiOverlayStyle overlay,
  required Locale locale,
}) {
  final isDark = brightness == Brightness.dark;
  final baseText = AppTypography.textTheme(brightness, locale);
  final scheme = appColorScheme(brightness);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: appColors.screenBackground,
    extensions: [appColors],
    textTheme: baseText,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: appColors.screenBackground,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: overlay,
      titleTextStyle: AppTypography.screenHeader(baseText, scheme.onSurface),
    ),
    cardTheme: CardThemeData(
      color: appColors.cardSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: appColors.cardSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: appColors.sheetSurface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(alpha: isDark ? 0.55 : 0.85),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppPalette.brandBlue;
        return isDark ? const Color(0xFF6A7380) : const Color(0xFFE0E4EA);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppPalette.brandBlue.withValues(alpha: 0.45);
        }
        return isDark ? const Color(0xFF3A424D) : const Color(0xFFD8DEE6);
      }),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: scheme.onSurface.withValues(alpha: 0.72),
      textColor: scheme.onSurface,
    ),
    inputDecorationTheme: AppFieldStyle.inputDecorationTheme(scheme),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: isDark ? const Color(0xFF2A3038) : const Color(0xFF1A1D21),
      contentTextStyle: baseText.bodyMedium?.copyWith(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppPalette.brandBlue,
      foregroundColor: AppPalette.white,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppPalette.brandBlue,
    ),
    iconTheme: IconThemeData(
      color: scheme.onSurface.withValues(alpha: 0.85),
    ),
  );
}

import 'package:daily_water_tracker/features/theme/ext.dart';
import 'package:daily_water_tracker/features/theme/shadow.dart';
import 'package:daily_water_tracker/features/theme/theme_colors.dart';
import 'package:flutter/material.dart';

/// Shared decorations, gradients, and modal chrome defaults.
abstract final class AppDecorations {
  static const Color transparent = Colors.transparent;

  static Color modalBarrier([double alpha = 0.45]) =>
      Colors.black.withValues(alpha: alpha);

  static Color loaderScrim([double alpha = 0.38]) =>
      Colors.black.withValues(alpha: alpha);

  static const LinearGradient primaryButton = LinearGradient(
    colors: AppPalette.primaryButtonGradientColors,
  );

  static const LinearGradient navFab = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: AppPalette.navFabGradientColors,
  );

  static const LinearGradient avatar = LinearGradient(
    colors: AppPalette.avatarGradientColors,
  );

  static const LinearGradient authLogo = LinearGradient(
    colors: AppPalette.authLogoGradientColors,
  );

  static List<BoxShadow> primaryButtonShadow() =>
      AppShadows.primaryButton(AppPalette.progressGradientHead);

  static const AppBarTheme clearAppBarOverlay = AppBarTheme(
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.transparent,
  );
}

/// Sign In / Sign Up card, fields, and dividers — kept separate from global theme.
abstract final class AppAuthStyle {
  static const ColorScheme _lightAuthScheme = ColorScheme.light(
    primary: AppPalette.brandBlue,
    secondary: AppPalette.brandBlue,
    onSecondary: AppPalette.white,
    error: AppPalette.cherryRed,
    surface: AppPalette.appBackground,
    surfaceContainerLowest: AppPalette.appBackground,
  );

  static const Color fieldEnabledBorderColor = AppPalette.blackShade;
  static const Color dividerLineColor = AppPalette.blackShade;

  static const List<BoxShadow> cardShadowLight = [
    BoxShadow(
      color: Color(0x1A0B1A33),
      blurRadius: 30,
      offset: Offset(0, 18),
    ),
    BoxShadow(
      color: Color(0x0D0B1A33),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(28));
  static const BorderRadius fieldRadius = BorderRadius.all(Radius.circular(16));

  static bool _isLight(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light;
  }

  static ColorScheme _schemeFor(BuildContext context) {
    return _isLight(context) ? _lightAuthScheme : Theme.of(context).colorScheme;
  }

  /// Light: frosted surface on grey scaffold. Dark: same elevated card as Home tab.
  static Color cardSurface(BuildContext context) {
    if (_isLight(context)) {
      return _lightAuthScheme.surface.withValues(alpha: 0.92);
    }
    return context.appColors.cardSurface;
  }

  static List<BoxShadow> cardShadow(BuildContext context) {
    if (_isLight(context)) return cardShadowLight;
    return context.appColors.cardShadow;
  }

  static BoxDecoration cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: cardSurface(context),
      borderRadius: cardRadius,
      boxShadow: cardShadow(context),
    );
  }

  static Color fieldFill(BuildContext context) {
    return _schemeFor(context).surfaceContainerHighest.withValues(alpha: 0.55);
  }

  static Color fieldFocusedBorder(BuildContext context) {
    return _schemeFor(context).primary;
  }

  static Color fieldErrorBorder(BuildContext context) {
    return _schemeFor(context).error;
  }

  static Color dividerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? dividerLineColor
        : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.8);
  }

  static InputDecoration fieldDecoration(
    BuildContext context, {
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    final focused = fieldFocusedBorder(context);
    final error = fieldErrorBorder(context);

    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fieldFill(context),
      border: AppFieldStyle.borderNone(),
      enabledBorder: AppFieldStyle.borderEnabled(),
      focusedBorder: AppFieldStyle.borderFocused(color: focused),
      errorBorder: AppFieldStyle.borderError(color: error),
      focusedErrorBorder: AppFieldStyle.borderFocusedError(
        color: error,
      ),
    );
  }
}

/// Shared text-field chrome across profile, preferences, and sheets.
abstract final class AppFieldStyle {
  static const Color enabledBorderColor = AppPalette.blackShade;
  static const BorderRadius radius16 = BorderRadius.all(Radius.circular(16));
  static const BorderRadius radius14 = BorderRadius.all(Radius.circular(14));
  static const double focusedBorderWidth = 1.4;

  static Color fillColor(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.55,
    );
  }

  static OutlineInputBorder borderNone([BorderRadius radius = radius16]) {
    return OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide.none,
    );
  }

  static OutlineInputBorder borderEnabled([BorderRadius radius = radius16]) {
    return OutlineInputBorder(
      borderRadius: radius,
      borderSide: const BorderSide(color: enabledBorderColor),
    );
  }

  static OutlineInputBorder borderFocused({
    Color color = AppPalette.brandBlue,
    BorderRadius radius = radius16,
    double width = focusedBorderWidth,
  }) {
    return OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static OutlineInputBorder borderError({
    required Color color,
    BorderRadius radius = radius16,
    double width = 1.2,
  }) {
    return OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static OutlineInputBorder borderFocusedError({
    required Color color,
    BorderRadius radius = radius16,
    double width = focusedBorderWidth,
  }) {
    return OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static OutlineInputBorder borderDisabled(
    BuildContext context, [
    BorderRadius radius = radius16,
  ]) {
    return OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(
        color: Theme.of(
          context,
        ).colorScheme.outlineVariant.withValues(alpha: 0.55),
      ),
    );
  }

  static InputDecorationTheme inputDecorationTheme(ColorScheme scheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
      border: borderNone(),
      enabledBorder: borderEnabled(),
      focusedBorder: borderFocused(),
      errorBorder: borderError(color: scheme.error),
      focusedErrorBorder: borderFocusedError(color: scheme.error),
    );
  }
}

BoxDecoration appCardDecoration(
  BuildContext context, {
  double radius = 22,
  Color? color,
}) {
  final colors = context.appColors;
  return BoxDecoration(
    color: color ?? colors.cardSurface,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: colors.cardShadow,
  );
}

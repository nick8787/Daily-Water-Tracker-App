import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography helpers — Plus Jakarta Sans (EN) and Montserrat (UK).
abstract final class AppTypography {
  static bool isUkrainian(Locale locale) => locale.languageCode == 'uk';

  static TextTheme textTheme(Brightness brightness, Locale locale) {
    final base = ThemeData(brightness: brightness).textTheme;
    if (isUkrainian(locale)) {
      return GoogleFonts.montserratTextTheme(base);
    }
    return GoogleFonts.plusJakartaSansTextTheme(base);
  }

  /// Pushed-route / in-body screen titles (Account header, AppBar titles).
  static TextStyle? screenHeader(TextTheme base, Color color) {
    return base.headlineSmall?.copyWith(
      fontWeight: FontWeight.w800,
      height: 1.05,
      color: color,
    );
  }

  static TextStyle progressRingCaption(Color color, TextTheme theme) {
    return (theme.labelMedium ?? const TextStyle()).copyWith(
      fontSize: 14,
      height: 1.2,
      fontWeight: FontWeight.w900,
      color: color,
    );
  }

  static TextStyle progressRingValue(Color color, TextTheme theme) {
    return (theme.displaySmall ?? const TextStyle()).copyWith(
      fontSize: 50,
      height: 1.02,
      fontWeight: FontWeight.w100,
      letterSpacing: -0.5,
      color: color,
    );
  }

  static TextStyle progressRingSubtitle(Color color, TextTheme theme) {
    return (theme.labelMedium ?? const TextStyle()).copyWith(
      fontSize: 14,
      height: 1.25,
      fontWeight: FontWeight.w900,
      color: color,
    );
  }

  static TextStyle sheetVolumeDisplay(Color color, TextTheme theme) {
    return (theme.displaySmall ?? const TextStyle()).copyWith(
      fontSize: 52,
      height: 1,
      fontWeight: FontWeight.w200,
      color: color,
    );
  }

  static TextStyle notifierTextLabel(Locale locale) {
    const base = TextStyle(
      fontSize: 26,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w300,
    );
    if (isUkrainian(locale)) {
      return GoogleFonts.montserrat(textStyle: base);
    }
    return GoogleFonts.plusJakartaSans(textStyle: base);
  }
}

/// Legacy typography access — prefer [AppTypography].
class TextStyles {
  static TextStyle notifierTextLabel(Locale locale) =>
      AppTypography.notifierTextLabel(locale);
}

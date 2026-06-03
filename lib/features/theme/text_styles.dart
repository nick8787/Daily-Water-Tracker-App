import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography helpers built on Plus Jakarta Sans (via Google Fonts).
abstract final class AppTypography {
  static TextTheme textTheme(Brightness brightness) {
    return GoogleFonts.plusJakartaSansTextTheme(
      ThemeData(brightness: brightness).textTheme,
    );
  }

  /// Pushed-route / in-body screen titles (Account header, AppBar titles).
  static TextStyle? screenHeader(TextTheme base, Color color) {
    return base.headlineSmall?.copyWith(
      fontWeight: FontWeight.w800,
      height: 1.05,
      color: color,
    );
  }

  static TextStyle progressRingCaption(Color color) {
    return TextStyle(
      fontSize: 14,
      height: 1.2,
      fontWeight: FontWeight.w900,
      color: color,
    );
  }

  static TextStyle progressRingValue(Color color) {
    return TextStyle(
      fontSize: 50,
      height: 1.02,
      fontWeight: FontWeight.w100,
      letterSpacing: -0.5,
      color: color,
    );
  }

  static TextStyle progressRingSubtitle(Color color) {
    return TextStyle(
      fontSize: 14,
      height: 1.25,
      fontWeight: FontWeight.w900,
      color: color,
    );
  }

  static TextStyle sheetVolumeDisplay(Color color) {
    return TextStyle(
      fontSize: 52,
      height: 1,
      fontWeight: FontWeight.w200,
      color: color,
    );
  }

  static const TextStyle notifierTextLabel = TextStyle(
    fontSize: 26,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w300,
  );
}

/// Legacy typography access — prefer [AppTypography].
class TextStyles {
  static const TextStyle notifierTextLabel = AppTypography.notifierTextLabel;
}

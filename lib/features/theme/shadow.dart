import 'package:daily_water_tracker/features/theme/theme_colors.dart';
import 'package:flutter/material.dart';

/// Reusable elevation shadows for cards, sheets, and chrome.
abstract final class AppShadows {
  static const List<BoxShadow> cardLight = [
    BoxShadow(
      color: AppPalette.greyLight,
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> cardDark = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> navBarLight = cardLight;

  static const List<BoxShadow> navBarDark = [
    BoxShadow(
      color: Color(0x45000000),
      blurRadius: 14,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> authCardLight = [
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

  static const List<BoxShadow> authCardDark = [
    BoxShadow(
      color: Color(0x50000000),
      blurRadius: 24,
      offset: Offset(0, 14),
    ),
  ];

  static const List<BoxShadow> navFab = [
    BoxShadow(
      color: AppPalette.greyLight,
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0xD00178D9),
      blurRadius: 20,
      spreadRadius: -19,
      offset: Offset(0, 15),
    ),
    BoxShadow(
      color: Color(0x660178D9),
      blurRadius: 34,
      spreadRadius: -22,
      offset: Offset(0, 19),
    ),
  ];

  static List<BoxShadow> primaryButton(Color headColor) => [
    BoxShadow(
      color: headColor.withValues(alpha: 0.38),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> softElevation({double alpha = 0.08}) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: alpha),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}

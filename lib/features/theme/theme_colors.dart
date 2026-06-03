import 'package:flutter/material.dart';

/// Raw palette tokens (brightness-agnostic). Prefer [AppColors] for UI surfaces.
abstract final class AppPalette {
  static const brandBlue = Color(0xFF12A0E6);
  static const brandBlueLight = Color(0xFF76A9C2);
  static const cherryRed = Color(0xFFE8001D);
  static const redLight = Color(0xFFE44125);
  static const successGreen = Color(0xFF1B9A59);

  static const white = Color(0xFFFFFFFF);
  static const blackShade = Color(0xFF222222);
  static const appBackground = Color(0xFFF1F1F1);
  static const greyShadeLight = Color(0xFFE5E5E5);
  static const greyLight = Color(0x0C000000);

  /// Home date bar & list accents.
  static const dateBarTitleLight = Color(0xFF163A5E);
  static const dateBarIcon = Color(0xFF7A93AD);
  static const dateBarIconDisabled = Color(0x3D7A93AD);

  /// Hydration progress ring.
  static const progressTrackLight = Color(0xFFF0F4F8);
  static const progressLabelMutedLight = Color(0xFF9EADBD);
  static const progressValueLight = Color(0xFF2C3E50);
  static const progressGradientTail = Color(0xFF6AB6FF);
  static const progressGradientMid = Color(0xFF2D86E1);
  static const progressGradientHead = Color(0xFF006FFF);
  static const progressRingTrackShadow = Color(0x10000000);

  static const homeEmptyMutedLight = Color(0xFFB3C2D4);
  static const homeEmptyCardMist = Color(0xFFBFD1E6);

  /// Primary CTA / bottom nav FAB.
  static const navFabGradientTop = Color(0xFF58ADF5);
  static const navFabGradientBottom = Color(0xFF0178D9);
  static const avatarGradientStart = Color(0xFF68B5F4);
  static const avatarGradientEnd = Color(0xFF028FE8);
  static const authLogoShadow = Color(0x3312A0E6);

  /// Drink-type accents (hydration sheets & rows).
  static const drinkCoffee = Color(0xFFB07A4A);
  static const drinkGreenTea = Color(0xFF7CB342);
  static const drinkMilk = Color(0xFF7EB8E8);

  /// Statistics highlights.
  static const statisticsGold = Color(0xFFD4A024);
  static const statisticsEmber = Color(0xFFE86B3A);
  static const chartTooltipBackground = Color(0xFF2C2C2E);
  static const chartPositive = Color(0xFF4ADE80);
  static const chartStubGrey = Color(0x229E9E9E);

  /// Today drinks list fade.
  static const drinksListFade = Color(0xFFAEBDCA);

  static const progressGradientColors = [
    progressGradientTail,
    progressGradientMid,
    progressGradientHead,
  ];

  static const primaryButtonGradientColors = [
    progressGradientMid,
    progressGradientHead,
  ];

  static const navFabGradientColors = [
    navFabGradientTop,
    navFabGradientBottom,
  ];

  static const avatarGradientColors = [
    avatarGradientStart,
    avatarGradientEnd,
  ];

  static const authLogoGradientColors = [
    brandBlue,
    brandBlueLight,
  ];
}

/// Third-party sign-in button brand colors (fixed by providers).
abstract final class SocialAuthColors {
  static const googleBackground = Color(0xFFFFFFFF);
  static const googleForeground = Color(0xFF1F1F1F);
  static const googleOutline = Color(0x140B1A33);

  static const facebookBackground = Color(0xFF1877F2);
  static const facebookForeground = Color(0xFFFFFFFF);

  static const appleBackground = Color(0xFF000000);
  static const appleForeground = Color(0xFFFFFFFF);
}

// Top-level aliases — keep existing `import .../theme_info.dart` call sites stable.
const Color brandBlue = AppPalette.brandBlue;
const Color cherryRed = AppPalette.cherryRed;
const Color redLight = AppPalette.redLight;
const Color white = AppPalette.white;
const Color blackShade = AppPalette.blackShade;
const Color appBackground = AppPalette.appBackground;
const Color greyShadeLight = AppPalette.greyShadeLight;
const Color greyLight = AppPalette.greyLight;
const Color successGreen = AppPalette.successGreen;

/// @deprecated Use [AppPalette.dateBarIcon] or `context.appColors.dateBarIcon`.
const Color kHomeDateBarInteractiveAccent = AppPalette.dateBarIcon;

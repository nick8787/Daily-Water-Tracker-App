import 'package:daily_water_tracker/features/theme/shadow.dart';
import 'package:daily_water_tracker/features/theme/theme_colors.dart';
import 'package:flutter/material.dart';

/// Semantic colors that adapt to light / dark mode (see [ThemeData.extensions]).
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.screenBackground,
    required this.cardSurface,
    required this.cardShadow,
    required this.sheetSurface,
    required this.sheetDragHandle,
    required this.waterSheetCardBg,
    required this.authCardSurface,
    required this.authCardShadow,
    required this.dateBarSurface,
    required this.dateBarTitle,
    required this.dateBarIcon,
    required this.dateBarIconDisabled,
    required this.progressTrack,
    required this.progressLabelMuted,
    required this.progressValueText,
    required this.homeEmptyMutedText,
    required this.navBarSurface,
    required this.navBarShadow,
    required this.inputFill,
    required this.avatarPlaceholderBg,
    required this.chipUnselectedBg,
    required this.chipUnselectedBorder,
    required this.disclaimerWarning,
    required this.disclaimerError,
    required this.disclaimerInfo,
  });

  final Color screenBackground;
  final Color cardSurface;
  final List<BoxShadow> cardShadow;
  final Color sheetSurface;
  final Color sheetDragHandle;
  final Color waterSheetCardBg;
  final Color authCardSurface;
  final List<BoxShadow> authCardShadow;
  final Color dateBarSurface;
  final Color dateBarTitle;
  final Color dateBarIcon;
  final Color dateBarIconDisabled;
  final Color progressTrack;
  final Color progressLabelMuted;
  final Color progressValueText;
  final Color homeEmptyMutedText;
  final Color navBarSurface;
  final List<BoxShadow> navBarShadow;
  final Color inputFill;
  final Color avatarPlaceholderBg;
  final Color chipUnselectedBg;
  final Color chipUnselectedBorder;
  final DisclaimerPalette disclaimerWarning;
  final DisclaimerPalette disclaimerError;
  final DisclaimerPalette disclaimerInfo;

  static const light = AppColors(
    screenBackground: AppPalette.appBackground,
    cardSurface: AppPalette.white,
    cardShadow: AppShadows.cardLight,
    sheetSurface: AppPalette.white,
    sheetDragHandle: Color(0x1A000000),
    waterSheetCardBg: Color(0xFFF8FAFC),
    authCardSurface: Color(0xEBFFFFFF),
    authCardShadow: AppShadows.authCardLight,
    dateBarSurface: AppPalette.white,
    dateBarTitle: AppPalette.dateBarTitleLight,
    dateBarIcon: AppPalette.dateBarIcon,
    dateBarIconDisabled: AppPalette.dateBarIconDisabled,
    progressTrack: AppPalette.progressTrackLight,
    progressLabelMuted: AppPalette.progressLabelMutedLight,
    progressValueText: AppPalette.progressValueLight,
    homeEmptyMutedText: AppPalette.homeEmptyMutedLight,
    navBarSurface: AppPalette.white,
    navBarShadow: AppShadows.navBarLight,
    inputFill: Color(0x8C000000),
    avatarPlaceholderBg: AppPalette.appBackground,
    chipUnselectedBg: AppPalette.white,
    chipUnselectedBorder: Color(0xFFE2E8EF),
    disclaimerWarning: DisclaimerPalette(
      bg: Color(0xFFFFF3E0),
      border: Color(0xFFF59E0B),
      text: Color(0xFF3B2B10),
      textMuted: Color(0xFF5A4420),
    ),
    disclaimerError: DisclaimerPalette(
      bg: Color(0xFFFFEBEE),
      border: Color(0xFFEF4444),
      text: Color(0xFF3C1111),
      textMuted: Color(0xFF5C1E1E),
    ),
    disclaimerInfo: DisclaimerPalette(
      bg: Color(0xFFEFF6FF),
      border: Color(0xFF3B82F6),
      text: Color(0xFF102A43),
      textMuted: Color(0xFF243B53),
    ),
  );

  static const dark = AppColors(
    screenBackground: Color(0xFF121418),
    cardSurface: Color(0xFF1E2228),
    cardShadow: AppShadows.cardDark,
    sheetSurface: Color(0xFF1E2228),
    sheetDragHandle: Color(0x33FFFFFF),
    waterSheetCardBg: Color(0xFF252A32),
    authCardSurface: Color(0xF01E2228),
    authCardShadow: AppShadows.authCardDark,
    dateBarSurface: Color(0xFF1E2228),
    dateBarTitle: Color(0xFFE8EDF3),
    dateBarIcon: Color(0xFF9BB4CC),
    dateBarIconDisabled: Color(0x3D9BB4CC),
    progressTrack: Color(0xFF2A3038),
    progressLabelMuted: Color(0xFF8A96A8),
    progressValueText: Color(0xFFE8EDF3),
    homeEmptyMutedText: Color(0xFF7A8FA6),
    navBarSurface: Color(0xFF1E2228),
    navBarShadow: AppShadows.navBarDark,
    inputFill: Color(0x14FFFFFF),
    avatarPlaceholderBg: Color(0xFF2A3038),
    chipUnselectedBg: Color(0xFF2A3038),
    chipUnselectedBorder: Color(0xFF3A424D),
    disclaimerWarning: DisclaimerPalette(
      bg: Color(0xFF3D2E14),
      border: Color(0xFFF59E0B),
      text: Color(0xFFFFE8C2),
      textMuted: Color(0xFFE6C99A),
    ),
    disclaimerError: DisclaimerPalette(
      bg: Color(0xFF3D1818),
      border: Color(0xFFEF4444),
      text: Color(0xFFFFD6D6),
      textMuted: Color(0xFFE8A8A8),
    ),
    disclaimerInfo: DisclaimerPalette(
      bg: Color(0xFF152A40),
      border: Color(0xFF3B82F6),
      text: Color(0xFFD6E8FF),
      textMuted: Color(0xFFA8C4E8),
    ),
  );

  @override
  AppColors copyWith({
    Color? screenBackground,
    Color? cardSurface,
    List<BoxShadow>? cardShadow,
    Color? sheetSurface,
    Color? sheetDragHandle,
    Color? waterSheetCardBg,
    Color? authCardSurface,
    List<BoxShadow>? authCardShadow,
    Color? dateBarSurface,
    Color? dateBarTitle,
    Color? dateBarIcon,
    Color? dateBarIconDisabled,
    Color? progressTrack,
    Color? progressLabelMuted,
    Color? progressValueText,
    Color? homeEmptyMutedText,
    Color? navBarSurface,
    List<BoxShadow>? navBarShadow,
    Color? inputFill,
    Color? avatarPlaceholderBg,
    Color? chipUnselectedBg,
    Color? chipUnselectedBorder,
    DisclaimerPalette? disclaimerWarning,
    DisclaimerPalette? disclaimerError,
    DisclaimerPalette? disclaimerInfo,
  }) {
    return AppColors(
      screenBackground: screenBackground ?? this.screenBackground,
      cardSurface: cardSurface ?? this.cardSurface,
      cardShadow: cardShadow ?? this.cardShadow,
      sheetSurface: sheetSurface ?? this.sheetSurface,
      sheetDragHandle: sheetDragHandle ?? this.sheetDragHandle,
      waterSheetCardBg: waterSheetCardBg ?? this.waterSheetCardBg,
      authCardSurface: authCardSurface ?? this.authCardSurface,
      authCardShadow: authCardShadow ?? this.authCardShadow,
      dateBarSurface: dateBarSurface ?? this.dateBarSurface,
      dateBarTitle: dateBarTitle ?? this.dateBarTitle,
      dateBarIcon: dateBarIcon ?? this.dateBarIcon,
      dateBarIconDisabled: dateBarIconDisabled ?? this.dateBarIconDisabled,
      progressTrack: progressTrack ?? this.progressTrack,
      progressLabelMuted: progressLabelMuted ?? this.progressLabelMuted,
      progressValueText: progressValueText ?? this.progressValueText,
      homeEmptyMutedText: homeEmptyMutedText ?? this.homeEmptyMutedText,
      navBarSurface: navBarSurface ?? this.navBarSurface,
      navBarShadow: navBarShadow ?? this.navBarShadow,
      inputFill: inputFill ?? this.inputFill,
      avatarPlaceholderBg: avatarPlaceholderBg ?? this.avatarPlaceholderBg,
      chipUnselectedBg: chipUnselectedBg ?? this.chipUnselectedBg,
      chipUnselectedBorder: chipUnselectedBorder ?? this.chipUnselectedBorder,
      disclaimerWarning: disclaimerWarning ?? this.disclaimerWarning,
      disclaimerError: disclaimerError ?? this.disclaimerError,
      disclaimerInfo: disclaimerInfo ?? this.disclaimerInfo,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return t < 0.5 ? this : other;
  }
}

@immutable
class DisclaimerPalette {
  const DisclaimerPalette({
    required this.bg,
    required this.border,
    required this.text,
    required this.textMuted,
  });

  final Color bg;
  final Color border;
  final Color text;
  final Color textMuted;
}

extension AppThemeContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}

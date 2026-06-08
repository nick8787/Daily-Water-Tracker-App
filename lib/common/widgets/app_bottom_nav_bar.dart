import 'dart:math' as math;

import 'package:daily_water_tracker/common/assets.dart';
import 'package:daily_water_tracker/features/main_nav/cubit/main_nav_cubit.dart';
import 'package:daily_water_tracker/features/theme/app_theme_extensions.dart';
import 'package:daily_water_tracker/features/theme/shadow.dart';
import 'package:daily_water_tracker/features/theme/theme_colors.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const String _kBottomNavStatisticsPng =
    'assets/images/ic_statistics_nav_bar.png';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onSelectTab,
    required this.onTapAdd,
    required this.onLongPressAdd,
  });

  final MainTab currentTab;
  final ValueChanged<MainTab> onSelectTab;
  final VoidCallback onTapAdd;
  final VoidCallback onLongPressAdd;

  static const double _edgeGap = 10;
  static const double _pillHorizontal = 16;
  static const double _pillHeight = 62;
  static const double _pillRadius = 28;
  static const double _fabSize = 92;
  static const double _fabRadius = 32;

  static double reservedHeight(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return _fabSize + _edgeGap * 2 + bottomInset;
  }

  /// Top of pill measured from the overlay stack bottom — matches [HomeTabScreen] layout.
  static double pillTopOffsetFromOverlayBottom(BuildContext context) =>
      _pillAnchorBottom(context) + _pillHeight;

  /// Symmetric gap below the home water card (`HomeTabScreen.minSymmetricGap`).
  static const double mainShellContentBottomGap = 28;

  /// Extra clearance tuned with [HomeTabScreen] (`bottomLayoutFudgePx`).
  static const double mainShellContentBottomFudge = 25;

  /// Height (logical px) up to which bottom spacing is already tuned — no bonus.
  static const double _compactScreenHeightReference = 852;

  /// Pro Max–class height where [mainShellLargeScreenClearanceBonus] reaches its max.
  static const double _largeScreenHeightReference = 932;

  /// Additional gap below content on tall phones (e.g. iPhone Pro Max).
  static const double mainShellLargeScreenClearanceBonus = 18;

  /// Visual gap between the bottom of main-shell content and the nav overlay.
  ///
  /// Shared by [MainShellTabBody], [HomeTabScreen], [StatisticsScreen], and [AccountScreen].
  static double mainShellContentBottomClearance(BuildContext context) =>
      mainShellContentBottomGap +
      pillTopOffsetFromOverlayBottom(context) +
      mainShellContentBottomFudge +
      _largeScreenBottomClearanceBonus(context);

  /// Ramps from 0 on compact phones to [mainShellLargeScreenClearanceBonus] on tall ones.
  static double _largeScreenBottomClearanceBonus(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    if (height <= _compactScreenHeightReference) return 0;

    const span = _largeScreenHeightReference - _compactScreenHeightReference;
    if (span <= 0) return mainShellLargeScreenClearanceBonus;

    final t = ((height - _compactScreenHeightReference) / span).clamp(0.0, 1.0);
    return mainShellLargeScreenClearanceBonus * t;
  }

  static double _pillAnchorBottom(BuildContext context) =>
      math.max(0.0, _pillAnchorBase - _navDownPx(context));

  static const double _pillAnchorBase = _edgeGap + (_fabSize - _pillHeight) / 2;

  /// Subtle shift toward the physical bottom on iOS (SafeArea sits high vs Android).
  static double _navDownPx(BuildContext context) {
    if (kIsWeb) return 0;
    return defaultTargetPlatform == TargetPlatform.iOS ? 10 : 0;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final down = _navDownPx(context);

    return SafeArea(
      top: false,
      child: SizedBox(
        height: AppBottomNavBar._fabSize + _edgeGap * 2 + bottomInset,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              left: _pillHorizontal,
              right: _pillHorizontal,
              bottom: _pillAnchorBottom(context),
              child: _Pill(
                height: _pillHeight,
                child: Row(
                  children: [
                    Expanded(
                      child: _NavItem(
                        labelKey: LocaleKeys.nav_statistics,
                        selected: currentTab == MainTab.statistics,
                        icon: Image.asset(
                          _kBottomNavStatisticsPng,
                          width: 22,
                          height: 22,
                          excludeFromSemantics: true,
                          filterQuality: FilterQuality.high,
                        ),
                        onTap: () => onSelectTab(MainTab.statistics),
                      ),
                    ),
                    const SizedBox(width: _fabSize + 12),
                    Expanded(
                      child: _NavItem(
                        labelKey: LocaleKeys.nav_account,
                        selected: currentTab == MainTab.account,
                        icon: Image.asset(
                          icAccountBlack,
                          width: 22,
                          height: 22,
                          color: brandBlue,
                          filterQuality: FilterQuality.high,
                        ),
                        onTap: () => onSelectTab(MainTab.account),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: math.max(0.0, _edgeGap - down),
              child: GestureDetector(
                onTap: onTapAdd,
                onLongPress: onLongPressAdd,
                child: _PlusButton(
                  selected: currentTab == MainTab.home,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.child, required this.height});

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colors.navBarSurface,
        borderRadius: BorderRadius.circular(AppBottomNavBar._pillRadius),
        boxShadow: colors.navBarShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppBottomNavBar._pillRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          child: child,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.labelKey,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  final String labelKey;
  final bool selected;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: selected
          ? brandBlue
          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
    );

    final label = labelKey.tr();

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(height: 4),
              Text(
                label,
                style: labelStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlusButton extends StatelessWidget {
  const _PlusButton({required this.selected});

  final bool selected;


  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: AppBottomNavBar._fabSize,
      height: AppBottomNavBar._fabSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppBottomNavBar._fabRadius),
        gradient: AppDecorations.navFab,
        boxShadow: AppShadows.navFab,
      ),
      child: const Icon(Icons.add, color: AppPalette.white, size: 60),
    );
  }
}

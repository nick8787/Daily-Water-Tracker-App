import 'dart:async';

import 'package:daily_water_tracker/features/theme/shadow.dart';
import 'package:daily_water_tracker/features/theme/theme_colors.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: avoid_classes_with_only_static_members
class AppSnackBar {
  static const double _horizontalInset = 16;
  static const double _topInset = 14;
  static const double _contentPaddingH = 16;
  static const double _contentPaddingV = 14;
  static const double _minHeight = 66;
  static const double _radius = 18;
  static const double _iconBoxSize = 40;
  static const double _iconSize = 23;

  static OverlayEntry? _currentOverlay;
  static AnimationController? _animationController;
  static Timer? _dismissTimer;

  static bool showError(BuildContext context, String message) {
    return _show(
      context,
      dismissAfter: const Duration(seconds: 3),
      icon: Icons.error_outline,
      iconColor: Theme.of(context).colorScheme.error,
      title: LocaleKeys.common_error.tr(),
      message: message,
      background: Theme.of(context).colorScheme.surface,
      borderColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.35),
    );
  }

  static bool showInfo(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return _show(
      context,
      dismissAfter: const Duration(seconds: 3),
      icon: Icons.info_outline,
      iconColor: Theme.of(context).colorScheme.primary,
      title: title,
      message: message,
      background: Theme.of(context).colorScheme.surface,
      borderColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.28),
    );
  }

  /// Success toast stays visible a bit longer so users can read the hydration math
  static bool showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    Duration dismissAfter = const Duration(seconds: 4),
  }) {
    return _show(
      context,
      dismissAfter: dismissAfter,
      icon: Icons.check_circle_outline,
      iconColor: AppPalette.successGreen,
      title: title,
      message: message,
      background: Theme.of(context).colorScheme.surface,
      borderColor: AppPalette.successGreen.withValues(alpha: 0.28),
    );
  }

  /// Rank ascension retention teaser
  static bool showRankRetentionTeaser(
    BuildContext context, {
    required String title,
    required String message,
    Duration dismissAfter = const Duration(seconds: 5),
  }) {
    HapticFeedback.mediumImpact();
    return _show(
      context,
      dismissAfter: dismissAfter,
      icon: Icons.emoji_events_outlined,
      iconColor: Theme.of(context).colorScheme.primary,
      title: title,
      message: message,
      background: Theme.of(context).colorScheme.surface,
      borderColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.28),
    );
  }

  static bool _show(
    BuildContext context, {
    required Duration dismissAfter,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required Color background,
    required Color borderColor,
  }) {
    _dismissTimer?.cancel();
    _dismissTimer = null;

    _removeCurrentOverlay(immediate: true);

    final NavigatorState? nav =
        Navigator.maybeOf(context, rootNavigator: true) ??
        Navigator.maybeOf(context);

    OverlayState? overlayState = nav?.overlay;
    overlayState ??= Overlay.maybeOf(context, rootOverlay: true);
    overlayState ??= Overlay.maybeOf(context);

    if (overlayState == null) {
      assert(() {
        debugPrint('AppSnackBar: could not resolve OverlayState');
        return true;
      }());
      return false;
    }

    final NavigatorState? navForTicker =
        nav ??
        Navigator.maybeOf(overlayState.context, rootNavigator: true) ??
        Navigator.maybeOf(overlayState.context);

    if (navForTicker == null) {
      assert(() {
        debugPrint('AppSnackBar: could not resolve NavigatorState');
        return true;
      }());
      return false;
    }

    final tickerContext = navForTicker.context;
    final topPadding = MediaQuery.paddingOf(tickerContext).top;

    final controller = AnimationController(
      vsync: navForTicker,
      duration: const Duration(milliseconds: 420),
      reverseDuration: const Duration(milliseconds: 260),
    );
    _animationController = controller;

    final offsetAnimation =
        Tween<Offset>(
          begin: const Offset(0, -1.1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    final overlayEntry = OverlayEntry(
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;

        return Positioned(
          top: topPadding + _topInset,
          left: _horizontalInset,
          right: _horizontalInset,
          child: Material(
            color: Colors.transparent,
            child: SlideTransition(
              position: offsetAnimation,
              child: GestureDetector(
                onTap: () => _removeCurrentOverlay(),
                onVerticalDragUpdate: (details) {
                  if ((details.primaryDelta ?? 0) < -6) _removeCurrentOverlay();
                },
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(_radius),
                    border: Border.all(
                      color: borderColor,
                      width: 1.2,
                    ),
                    boxShadow: [
                      ...AppShadows.softElevation(alpha: 0.10),
                      BoxShadow(
                        color: scheme.shadow.withValues(alpha: 0.14),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: _minHeight),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _contentPaddingH,
                        vertical: _contentPaddingV,
                      ),
                      child: Row(
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: iconColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: SizedBox(
                              width: _iconBoxSize,
                              height: _iconBoxSize,
                              child: Icon(
                                icon,
                                color: iconColor,
                                size: _iconSize,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.2,
                                        height: 1.2,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  message,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: scheme.onSurface.withValues(
                                          alpha: 0.74,
                                        ),
                                        height: 1.35,
                                        letterSpacing: -0.1,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    _currentOverlay = overlayEntry;
    overlayState.insert(overlayEntry);
    controller.forward();

    _dismissTimer = Timer(dismissAfter, () {
      if (_currentOverlay == overlayEntry) _removeCurrentOverlay();
    });
    return true;
  }

  static void _removeCurrentOverlay({bool immediate = false}) {
    _dismissTimer?.cancel();
    _dismissTimer = null;

    final entry = _currentOverlay;
    final controller = _animationController;

    if (entry == null || controller == null) return;

    _currentOverlay = null;
    _animationController = null;

    if (immediate) {
      entry.remove();
      controller.dispose();
      return;
    }

    controller.reverse().then((_) {
      entry.remove();
      controller.dispose();
    });
  }
}

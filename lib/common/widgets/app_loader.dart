import 'dart:async';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

import 'app_snackbar.dart';

// ignore: avoid_classes_with_only_static_members
class AppLoader {
  static OverlayEntry? _currentOverlay;
  static AnimationController? _animationController;
  static Timer? _timeoutTimer;
  static DateTime? _loaderShownAt;

  /// Bumped on each [show]; [hideWithMinimumVisibleDuration] ignores stale awaits after a newer show.
  static int _loaderShowToken = 0;

  static bool get isShowing => _currentOverlay != null;

  static void show(
    BuildContext context, {
    String? message,
    Duration timeout = const Duration(seconds: 25),
    String? timeoutMessage,
  }) {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;

    _remove(immediate: true);

    final resolvedMessage = message ?? LocaleKeys.common_loading.tr();
    final resolvedTimeoutMessage =
        timeoutMessage ?? LocaleKeys.loader_timeout.tr();

    final overlayState = Overlay.of(context, rootOverlay: true);
    final nav = Navigator.of(context, rootNavigator: true);
    final controller = AnimationController(
      vsync: nav,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _animationController = controller;

    final fade = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    final scale = Tween<double>(begin: 0.98, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    final entry = OverlayEntry(
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return Stack(
          children: [
            // Blocks interaction without shifting layout.
            AnimatedBuilder(
              animation: fade,
              builder: (context, child) => Opacity(
                opacity: fade.value,
                child: child,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: ModalBarrier(
                  dismissible: false,
                  // Slight dim + mild blur to keep context readable.
                  color: Colors.black.withValues(alpha: 0.38),
                ),
              ),
            ),
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([fade, scale]),
                builder: (context, child) => Opacity(
                  opacity: fade.value,
                  child: Transform.scale(
                    scale: scale.value,
                    child: child,
                  ),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.50),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.shadow.withValues(alpha: 0.14),
                        blurRadius: 30,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 240),
                          child: Text(
                            resolvedMessage,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface.withValues(alpha: 0.88),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    _currentOverlay = entry;
    overlayState.insert(entry);
    controller.forward();
    _loaderShownAt = DateTime.now();
    _loaderShowToken++;

    if (timeout != Duration.zero) {
      _timeoutTimer = Timer(timeout, () {
        if (_currentOverlay == entry) {
          hide();
          AppSnackBar.showError(context, resolvedTimeoutMessage);
        }
      });
    }
  }

  static void hide() => _remove(immediate: false);

  /// Hides the loader after it has been visible at least [minimumVisible] (default 1s),
  /// so quick saves still read as feedback. Safe if overlay was replaced or already hidden.
  static Future<void> hideWithMinimumVisibleDuration([
    Duration minimumVisible = const Duration(seconds: 1),
  ]) async {
    if (_currentOverlay == null) return;
    final token = _loaderShowToken;
    final since = _loaderShownAt ?? DateTime.now();
    final elapsed = DateTime.now().difference(since);
    if (elapsed < minimumVisible) {
      await Future<void>.delayed(minimumVisible - elapsed);
    }
    if (_currentOverlay == null || _loaderShowToken != token) return;
    hide();
  }

  static void _remove({required bool immediate}) {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    _loaderShownAt = null;

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

import 'package:daily_water_tracker/common/di/injector_module.dart';
import 'package:daily_water_tracker/common/utils/crashlytics.dart';
import 'package:daily_water_tracker/features/achievements/models/badge_model.dart';
import 'package:daily_water_tracker/features/deep_links/services/water_deep_link_service.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// Builds localized share payloads for hydration progress deep links.
abstract final class ProgressShareService {
  ProgressShareService._();

  static WaterDeepLinkService get _deepLinks =>
      InjectorModule.locator<WaterDeepLinkService>();

  /// Resolves the popover anchor for iOS share sheets (`UIActivityViewController`).
  ///
  /// Required on iPad; on iPhone it avoids presentation failures from modals/overlays.
  static Rect sharePositionOriginFor(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      return box.localToGlobal(Offset.zero) & box.size;
    }

    final size = MediaQuery.sizeOf(context);
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 1,
      height: 1,
    );
  }

  static Future<void> shareTodayProgress({
    required BuildContext context,
    required int ml,
    required String locale,
  }) {
    return _share(
      context: context,
      ml: ml,
      locale: locale,
      buildMessage: (formattedMl, uri) =>
          LocaleKeys.deep_link_share_progress_message.tr(
        namedArgs: {
          'ml': formattedMl,
          'url': uri.toString(),
        },
      ),
    );
  }

  static Future<void> shareRankCelebration({
    required BuildContext context,
    required BadgeModel rank,
    required int ml,
    required String locale,
  }) {
    return _share(
      context: context,
      ml: ml,
      locale: locale,
      buildMessage: (formattedMl, uri) =>
          LocaleKeys.achievements_celebration_share_message.tr(
        namedArgs: {
          'rank': rank.nameKey.tr(),
          'ml': formattedMl,
          'url': uri.toString(),
        },
      ),
    );
  }

  static Future<void> _share({
    required BuildContext context,
    required int ml,
    required String locale,
    required String Function(String formattedMl, Uri uri) buildMessage,
  }) async {
    try {
      HapticFeedback.lightImpact();
      final formattedMl = NumberFormat.decimalPattern(locale).format(ml);
      final uri = _deepLinks.buildShareProgressUri(ml: ml);
      final message = buildMessage(formattedMl, uri);
      await SharePlus.instance.share(
        ShareParams(
          text: message,
          sharePositionOrigin: sharePositionOriginFor(context),
        ),
      );
    } catch (e, st) {
      await recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'ProgressShareService._share',
      );
      rethrow;
    }
  }
}

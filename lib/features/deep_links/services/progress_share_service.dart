import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

import 'package:daily_water_tracker/common/di/injector_module.dart';
import 'package:daily_water_tracker/common/services/logger.dart';
import 'package:daily_water_tracker/features/achievements/models/badge_model.dart';
import 'package:daily_water_tracker/features/deep_links/services/water_deep_link_service.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:share_plus/share_plus.dart';

/// Builds localized share payloads for hydration progress deep links.
abstract final class ProgressShareService {
  ProgressShareService._();

  static WaterDeepLinkService get _deepLinks =>
      InjectorModule.locator<WaterDeepLinkService>();

  static Future<void> shareTodayProgress({
    required int ml,
    required String locale,
  }) {
    return _share(
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
    required BadgeModel rank,
    required int ml,
    required String locale,
  }) {
    return _share(
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
    required int ml,
    required String locale,
    required String Function(String formattedMl, Uri uri) buildMessage,
  }) async {
    try {
      HapticFeedback.lightImpact();
      final formattedMl = NumberFormat.decimalPattern(locale).format(ml);
      final uri = _deepLinks.buildShareProgressUri(ml: ml);
      final message = buildMessage(formattedMl, uri);
      await SharePlus.instance.share(ShareParams(text: message));
    } catch (e, st) {
      logCaughtError('ProgressShareService._share', e, st);
      rethrow;
    }
  }
}

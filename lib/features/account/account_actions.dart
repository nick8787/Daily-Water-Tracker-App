import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

import 'package:daily_water_tracker/common/di/injector_module.dart';
import 'package:daily_water_tracker/common/services/app_bootstrapper.dart';
import 'package:daily_water_tracker/common/services/logger.dart';
import 'package:daily_water_tracker/common/widgets/app_loader.dart';
import 'package:daily_water_tracker/common/widgets/app_snackbar.dart';
import 'package:daily_water_tracker/data/repositories/firestore_repository.dart';
import 'package:daily_water_tracker/features/deep_links/services/water_deep_link_service.dart';
import 'package:share_plus/share_plus.dart';

abstract final class AccountActions {
  AccountActions._();

  static Future<void> onShareProgressTap(BuildContext context) async {
    if (flutterFlavor.isProd) {
      comingSoon(context, LocaleKeys.account_menu_share_progress.tr());
      return;
    }
    await shareTodayProgress(context);
  }

  static Future<void> shareTodayProgress(BuildContext context) async {
    final firestore = context.read<FirestoreRepository>();
    final deepLinks = InjectorModule.locator<WaterDeepLinkService>();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    try {
      AppLoader.show(context, message: LocaleKeys.loader_preparing_share.tr());
      final records = await firestore.watchDayRecords(today).first;
      final totalMl = records.fold<int>(0, (sum, r) => sum + r.volumeMl);

      if (!context.mounted) return;
      AppLoader.hide();

      if (totalMl <= 0) {
        AppSnackBar.showInfo(
          context,
          title: LocaleKeys.account_snackbar_nothing_to_share_title.tr(),
          message: LocaleKeys.account_snackbar_nothing_to_share_message.tr(),
        );
        return;
      }

      final uri = deepLinks.buildShareProgressUri(ml: totalMl);
      await SharePlus.instance.share(
        ShareParams(
          text: uri.toString(),
        ),
      );
    } catch (e, st) {
      logCaughtError('AccountActions.shareTodayProgress', e, st);
      if (AppLoader.isShowing) AppLoader.hide();
      if (context.mounted) {
        AppSnackBar.showError(
          context,
          LocaleKeys.account_snackbar_share_failed.tr(),
        );
      }
    }
  }

  static void comingSoon(BuildContext context, String feature) {
    AppSnackBar.showInfo(
      context,
      title: LocaleKeys.common_coming_soon_title.tr(),
      message: LocaleKeys.common_coming_soon_body.tr(
        namedArgs: {'feature': feature},
      ),
    );
  }
}

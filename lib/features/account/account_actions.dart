import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

import 'package:daily_water_tracker/common/services/logger.dart';
import 'package:daily_water_tracker/common/widgets/app_confirm_dialog.dart';
import 'package:daily_water_tracker/common/widgets/app_loader.dart';
import 'package:daily_water_tracker/common/widgets/app_snackbar.dart';
import 'package:daily_water_tracker/data/repositories/firestore_repository.dart';
import 'package:daily_water_tracker/features/account/cubit/account_cubit.dart';
import 'package:daily_water_tracker/features/deep_links/services/progress_share_service.dart';

abstract final class AccountActions {
  AccountActions._();

  static Future<void> onShareProgressTap(BuildContext context) async {
    await shareTodayProgress(context);
  }

  static Future<void> shareTodayProgress(BuildContext context) async {
    final firestore = context.read<FirestoreRepository>();

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

      final locale = Localizations.localeOf(context).toString();
      await ProgressShareService.shareTodayProgress(
        context: context,
        ml: totalMl,
        locale: locale,
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

  static Future<void> confirmAndLogOut(BuildContext context) async {
    final cubit = context.read<AccountCubit>();
    if (cubit.state.isSessionActionInProgress) return;

    final confirmed = await showAppConfirmDialog(
      context: context,
      title: LocaleKeys.account_dialog_logout_title.tr(),
      message: LocaleKeys.account_dialog_logout_message.tr(),
      confirmText: LocaleKeys.account_dialog_logout_confirm.tr(),
      intent: AppConfirmIntent.affirmative,
      icon: Icons.logout_rounded,
    );
    if (confirmed != true || !context.mounted) return;

    await WidgetsBinding.instance.endOfFrame;
    if (!context.mounted) return;

    await cubit.logOut();
  }
}

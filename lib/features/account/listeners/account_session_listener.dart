import 'package:daily_water_tracker/common/widgets/app_loader.dart';
import 'package:daily_water_tracker/common/widgets/app_snackbar.dart';
import 'package:daily_water_tracker/features/account/cubit/account_cubit.dart';
import 'package:daily_water_tracker/features/account/cubit/account_state.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Side effects for [AccountCubit] photo uploads and feedback on the account tab.
///
/// Logout and delete account from Settings → More use [AccountMoreSessionListener].
class AccountSessionListener extends StatelessWidget {
  const AccountSessionListener({super.key, required this.child});

  final Widget child;

  static bool listenWhen(AccountState prev, AccountState next) {
    if (prev.sessionPhase != next.sessionPhase) return true;
    if (prev.sessionAction != next.sessionAction) return true;
    if (prev.feedback != next.feedback &&
        next.feedback != AccountFeedback.none) {
      return true;
    }
    return prev.isPhotoBusy != next.isPhotoBusy;
  }

  static void handleSession(BuildContext context, AccountState state) {
    final cubit = context.read<AccountCubit>();

    if (state.sessionAction != AccountSessionAction.none) return;

    if (state.isSessionActionInProgress) return;

    if (state.isPhotoBusy) {
      AppLoader.show(context, message: LocaleKeys.loader_updating_photo.tr());
      return;
    }

    if (AppLoader.isShowing) AppLoader.hide();

    if (!state.hasFeedback) return;

    switch (state.feedback) {
      case AccountFeedback.success:
        AppSnackBar.showInfo(
          context,
          title: LocaleKeys.account_success_title.tr(),
          message: state.localizedFeedbackMessage(),
        );
      case AccountFeedback.error:
        AppSnackBar.showError(context, state.localizedFeedbackMessage());
      case AccountFeedback.none:
        break;
    }
    cubit.clearFeedback();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountCubit, AccountState>(
      listenWhen: listenWhen,
      listener: handleSession,
      child: child,
    );
  }
}

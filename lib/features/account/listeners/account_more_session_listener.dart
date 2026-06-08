import 'package:daily_water_tracker/common/router.dart';
import 'package:daily_water_tracker/common/widgets/account_signing_out_overlay.dart';
import 'package:daily_water_tracker/common/widgets/app_snackbar.dart';
import 'package:daily_water_tracker/features/account/cubit/account_cubit.dart';
import 'package:daily_water_tracker/features/account/cubit/account_state.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Whether Settings → More should block interaction (logout / delete flows).
bool isMoreSessionBlocked(AccountState state) {
  if (state.isLogoutInProgress) return true;
  if (state.isSessionActionInProgress) return true;
  if (state.sessionAction == AccountSessionAction.deleteAccount &&
      state.sessionPhase == AccountSessionPhase.succeeded) {
    return true;
  }
  return false;
}

bool _isDeletingAccountOverlayVisible(AccountState state) {
  if (state.sessionAction != AccountSessionAction.deleteAccount) return false;
  return state.sessionPhase == AccountSessionPhase.inProgress ||
      state.sessionPhase == AccountSessionPhase.succeeded;
}

/// Session side effects for Settings → More (logout + delete account).
class AccountMoreSessionListener extends StatelessWidget {
  const AccountMoreSessionListener({super.key, required this.child});

  final Widget child;

  static bool _listenWhen(AccountState prev, AccountState next) {
    if (next.sessionAction == AccountSessionAction.none) return false;
    if (next.sessionAction != AccountSessionAction.logout &&
        next.sessionAction != AccountSessionAction.deleteAccount) {
      return false;
    }
    return prev.sessionPhase != next.sessionPhase ||
        prev.sessionAction != next.sessionAction;
  }

  static void _handleSession(BuildContext context, AccountState state) {
    final cubit = context.read<AccountCubit>();

    if (state.sessionAction == AccountSessionAction.logout) {
      switch (state.sessionPhase) {
        case AccountSessionPhase.inProgress:
          return;
        case AccountSessionPhase.succeeded:
          goRouter.go(loginRoute);
          return;
        case AccountSessionPhase.failed:
          final message = state.sessionErrorText();
          if (message.isNotEmpty) {
            AppSnackBar.showError(context, message);
          }
          cubit.clearSession();
          return;
        case AccountSessionPhase.idle:
          break;
      }
    }

    if (state.sessionAction == AccountSessionAction.deleteAccount) {
      switch (state.sessionPhase) {
        case AccountSessionPhase.inProgress:
          return;
        case AccountSessionPhase.succeeded:
          goRouter.go(loginRoute);
          return;
        case AccountSessionPhase.failed:
          final message = state.sessionErrorText();
          if (message.isNotEmpty) {
            AppSnackBar.showError(context, message);
          }
          cubit.clearSession();
          return;
        case AccountSessionPhase.idle:
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountCubit, AccountState>(
      listenWhen: _listenWhen,
      listener: _handleSession,
      child: child,
    );
  }
}

/// Blocks back navigation and shows session overlays on Settings → More.
class AccountMoreSessionMask extends StatelessWidget {
  const AccountMoreSessionMask({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final state = context.select<AccountCubit, AccountState>((c) => c.state);
    final signingOut = state.isLogoutInProgress;
    final deletingAccount = _isDeletingAccountOverlayVisible(state);
    final sessionBlocked = isMoreSessionBlocked(state);

    return PopScope(
      canPop: !sessionBlocked,
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          if (signingOut) const AccountSigningOutOverlay(),
          if (!signingOut && deletingAccount)
            AccountSigningOutOverlay(
              message: LocaleKeys.loader_deleting_account.tr(),
            ),
        ],
      ),
    );
  }
}

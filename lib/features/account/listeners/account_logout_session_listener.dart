import 'package:daily_water_tracker/common/router.dart';
import 'package:daily_water_tracker/common/widgets/account_signing_out_overlay.dart';
import 'package:daily_water_tracker/common/widgets/app_snackbar.dart';
import 'package:daily_water_tracker/features/account/cubit/account_cubit.dart';
import 'package:daily_water_tracker/features/account/cubit/account_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Logout side effects when the user confirms sign-out on a pushed account route
/// (e.g. Settings → More). Shows [AccountSigningOutOverlay] on this screen.
class AccountLogoutSessionListener extends StatelessWidget {
  const AccountLogoutSessionListener({super.key, required this.child});

  final Widget child;

  static bool _listenWhen(AccountState prev, AccountState next) {
    if (next.sessionAction != AccountSessionAction.logout) {
      return false;
    }
    return prev.sessionPhase != next.sessionPhase ||
        prev.sessionAction != next.sessionAction;
  }

  static void _onLogoutSession(BuildContext context, AccountState state) {
    if (state.sessionAction != AccountSessionAction.logout) return;

    final cubit = context.read<AccountCubit>();
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountCubit, AccountState>(
      listenWhen: _listenWhen,
      listener: _onLogoutSession,
      child: child,
    );
  }
}

/// Full-screen sign-out overlay for pushed account routes.
class AccountLogoutSigningOutMask extends StatelessWidget {
  const AccountLogoutSigningOutMask({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final signingOut = context.select<AccountCubit, bool>(
      (c) => c.state.isLogoutInProgress,
    );

    return PopScope(
      canPop: !signingOut,
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          if (signingOut) const AccountSigningOutOverlay(),
        ],
      ),
    );
  }
}

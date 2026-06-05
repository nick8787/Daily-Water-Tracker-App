import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_water_tracker/common/di/injector_module.dart';
import 'package:daily_water_tracker/common/router.dart';
import 'package:daily_water_tracker/common/widgets/app_bottom_nav_bar.dart';
import 'package:daily_water_tracker/common/widgets/app_confirm_dialog.dart';
import 'package:daily_water_tracker/common/widgets/app_loader.dart';
import 'package:daily_water_tracker/common/widgets/app_notification_settings_dialog.dart';
import 'package:daily_water_tracker/common/widgets/app_snackbar.dart';
import 'package:daily_water_tracker/features/account/account_actions.dart';
import 'package:daily_water_tracker/features/account/cubit/account_cubit.dart';
import 'package:daily_water_tracker/features/account/cubit/account_state.dart';
import 'package:daily_water_tracker/features/account/widgets/account_app_bar.dart';
import 'package:daily_water_tracker/features/account/widgets/account_logout_footer.dart';
import 'package:daily_water_tracker/features/account/widgets/account_menu_section.dart';
import 'package:daily_water_tracker/features/account/widgets/account_user_info_section.dart';
import 'package:daily_water_tracker/features/main_nav/cubit/main_nav_cubit.dart';
import 'package:daily_water_tracker/firebase/services/auth_service.dart';
import 'package:daily_water_tracker/data/repositories/firestore_repository.dart';
import 'package:daily_water_tracker/firebase/services/local_notifications_service.dart';
import 'package:daily_water_tracker/data/repositories/messaging_repository.dart';
import 'package:daily_water_tracker/firebase/services/reminder_scheduler_service.dart';
import 'package:daily_water_tracker/data/repositories/storage_repository.dart';
import 'package:daily_water_tracker/firebase/services/user_account_deletion_service.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AccountCubit(
        authService: InjectorModule.locator<AuthService>(),
        firestoreRepository: context.read<FirestoreRepository>(),
        storageRepository: context.read<StorageRepository>(),
        reminderScheduler: context.read<ReminderSchedulerService>(),
        messagingRepository: context.read<MessagingRepository>(),
        localNotifications: InjectorModule.locator<LocalNotificationsService>(),
        accountDeletionService: context.read<UserAccountDeletionService>(),
      ),
      child: const AccountScreenView(),
    );
  }
}

class AccountScreenView extends StatelessWidget {
  const AccountScreenView({super.key});

  static const Duration _deleteMinDisplay = Duration(seconds: 1);

  static bool _listenWhen(AccountState prev, AccountState next) {
    if (prev.sessionPhase != next.sessionPhase) return true;
    if (prev.sessionAction != next.sessionAction) return true;
    if (prev.feedback != next.feedback &&
        next.feedback != AccountFeedback.none) {
      return true;
    }
    return prev.isPhotoBusy != next.isPhotoBusy;
  }

  static void _listener(BuildContext context, AccountState state) {
    final cubit = context.read<AccountCubit>();
    final mainNav = context.read<MainNavCubit>();

    if (state.sessionAction == AccountSessionAction.logout) {
      switch (state.sessionPhase) {
        case AccountSessionPhase.inProgress:
          mainNav.setAccountSigningOutMask(true);
          return;
        case AccountSessionPhase.succeeded:
          goRouter.go(loginRoute);
          return;
        case AccountSessionPhase.failed:
          mainNav.setAccountSigningOutMask(false);
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
          AppLoader.show(
            context,
            message: LocaleKeys.loader_deleting_account.tr(),
          );
          return;
        case AccountSessionPhase.succeeded:
          unawaited(
            AppLoader.hideWithMinimumVisibleDuration(_deleteMinDisplay),
          );
          goRouter.go(loginRoute);
          return;
        case AccountSessionPhase.failed:
          unawaited(
            AppLoader.hideWithMinimumVisibleDuration(_deleteMinDisplay),
          );
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

  Future<void> _onNotificationsToggle(BuildContext context, bool wantOn) async {
    final cubit = context.read<AccountCubit>();
    final blocked = await cubit.setAppNotificationsEnabled(wantOn);
    if (!context.mounted) return;
    if (blocked) {
      await showNotificationSettingsDialog(context: context);
    }
  }

  Future<void> _onLogOutPressed(BuildContext context) async {
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

  @override
  Widget build(BuildContext context) {
    return _AccountLifecycleSync(
      child: BlocConsumer<AccountCubit, AccountState>(
        listenWhen: _listenWhen,
        listener: _listener,
        builder: (context, state) {
          final sessionBusy = state.isSessionActionInProgress;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              bottom: false,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        children: [
                          const AccountAppBar(),
                          Expanded(
                            child: IgnorePointer(
                              ignoring: sessionBusy,
                              child: _AccountScrollableBody(
                                scrollEnabled: !sessionBusy,
                                signingOut: state.isLogoutInProgress,
                                logoutFreeze: state.logoutUiFreeze,
                                sessionBusy: sessionBusy,
                                onNotificationsToggle: _onNotificationsToggle,
                                onShareProgress: AccountActions.onShareProgressTap,
                                onComingSoon: AccountActions.comingSoon,
                                onLogOutPressed: () => _onLogOutPressed(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Menu card grows on tall screens; fixed gaps keep profile/nav spacing tight.
class _AccountScrollableBody extends StatelessWidget {
  const _AccountScrollableBody({
    required this.scrollEnabled,
    required this.signingOut,
    required this.logoutFreeze,
    required this.sessionBusy,
    required this.onNotificationsToggle,
    required this.onShareProgress,
    required this.onComingSoon,
    required this.onLogOutPressed,
  });

  final bool scrollEnabled;
  final bool signingOut;
  final AccountLogoutUiFreeze? logoutFreeze;
  final bool sessionBusy;
  final void Function(BuildContext context, bool value) onNotificationsToggle;
  final Future<void> Function(BuildContext context) onShareProgress;
  final void Function(BuildContext context, String feature) onComingSoon;
  final VoidCallback onLogOutPressed;

  static const double _horizontalPadding = 20;
  static const double _sectionGap = 16;
  static const double _navBarTopGap = 24;
  static const double _profileEstimate = 132;
  static const double _logoutEstimate = 44;
  static const double _minMenuIntrinsic = 468;
  /// Share of free height given to the menu card; the rest is even edge spacing.
  static const double _menuExtraGrowthFactor = 0.72;

  static ({double middleHeight, double edgeSpacer}) _resolveExpandedMiddleLayout({
    required double viewportHeight,
    required double bottomOffset,
  }) {
    final fixedTop = _profileEstimate + _sectionGap;
    final fixedBottom = _sectionGap + bottomOffset;
    final middleZoneMax = math.max(
      0.0,
      viewportHeight - fixedTop - fixedBottom,
    );
    final middleBlockMin =
        _minMenuIntrinsic +
        _logoutEstimate +
        _AccountMenuAndLogoutBlock._menuToLogoutGap;
    final growthBudget = math.max(0.0, middleZoneMax - middleBlockMin);
    final appliedGrowth = growthBudget * _menuExtraGrowthFactor;
    final middleHeight = middleBlockMin + appliedGrowth;
    final edgeSpacer = math.max(0.0, (middleZoneMax - middleHeight) / 2);

    return (middleHeight: middleHeight, edgeSpacer: edgeSpacer);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bottomOffset =
            AppBottomNavBar.pillTopOffsetFromOverlayBottom(context) +
            _navBarTopGap;
        final chromeHeight =
            _profileEstimate +
            _logoutEstimate +
            _AccountMenuAndLogoutBlock._menuToLogoutGap +
            _sectionGap * 2 +
            bottomOffset;
        final expandVertically =
            constraints.maxHeight >= chromeHeight + _minMenuIntrinsic;
        final expandedLayout = expandVertically
            ? _resolveExpandedMiddleLayout(
                viewportHeight: constraints.maxHeight,
                bottomOffset: bottomOffset,
              )
            : null;
        final scrollPhysics = scrollEnabled
            ? const ClampingScrollPhysics()
            : const NeverScrollableScrollPhysics();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
          child: SingleChildScrollView(
            physics: scrollPhysics,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AccountUserInfoSection(
                      signingOut: signingOut,
                      logoutFreeze: logoutFreeze,
                    ),
                    const SizedBox(height: _sectionGap),
                    if (expandVertically) ...[
                      if (expandedLayout!.edgeSpacer > 0)
                        SizedBox(height: expandedLayout.edgeSpacer),
                      SizedBox(
                        height: expandedLayout.middleHeight,
                        child: _AccountMenuAndLogoutBlock(
                          expandVertically: true,
                          sessionBusy: sessionBusy,
                          onNotificationsToggle: onNotificationsToggle,
                          onShareProgress: onShareProgress,
                          onComingSoon: onComingSoon,
                          onLogOutPressed: onLogOutPressed,
                        ),
                      ),
                      if (expandedLayout.edgeSpacer > 0)
                        SizedBox(height: expandedLayout.edgeSpacer),
                    ] else ...[
                      _AccountMenuAndLogoutBlock(
                        expandVertically: false,
                        sessionBusy: sessionBusy,
                        onNotificationsToggle: onNotificationsToggle,
                        onShareProgress: onShareProgress,
                        onComingSoon: onComingSoon,
                        onLogOutPressed: onLogOutPressed,
                      ),
                      const Spacer(),
                    ],
                    const SizedBox(height: _sectionGap),
                    SizedBox(height: bottomOffset),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Menu card and logout button are laid out as a single visual unit.
class _AccountMenuAndLogoutBlock extends StatelessWidget {
  const _AccountMenuAndLogoutBlock({
    required this.expandVertically,
    required this.sessionBusy,
    required this.onNotificationsToggle,
    required this.onShareProgress,
    required this.onComingSoon,
    required this.onLogOutPressed,
  });

  final bool expandVertically;
  final bool sessionBusy;
  final void Function(BuildContext context, bool value) onNotificationsToggle;
  final Future<void> Function(BuildContext context) onShareProgress;
  final void Function(BuildContext context, String feature) onComingSoon;
  final VoidCallback onLogOutPressed;

  static const double _menuToLogoutGap = 16;

  @override
  Widget build(BuildContext context) {
    final menu = AccountMenuSection(
      expandVertically: expandVertically,
      onNotificationsToggle: onNotificationsToggle,
      onShareProgress: onShareProgress,
      onComingSoon: onComingSoon,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize:
          expandVertically ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (expandVertically) Expanded(child: menu) else menu,
        const SizedBox(height: _menuToLogoutGap),
        AccountLogoutFooter(
          actionsEnabled: !sessionBusy,
          onLogOutPressed: onLogOutPressed,
        ),
      ],
    );
  }
}

class _AccountLifecycleSync extends StatefulWidget {
  const _AccountLifecycleSync({required this.child});

  final Widget child;

  @override
  State<_AccountLifecycleSync> createState() => _AccountLifecycleSyncState();
}

class _AccountLifecycleSyncState extends State<_AccountLifecycleSync>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<AccountCubit>().refreshOsNotificationSync();
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

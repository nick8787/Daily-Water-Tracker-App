import 'dart:async';

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
                              child: ListView(
                                physics: sessionBusy
                                    ? const NeverScrollableScrollPhysics()
                                    : const BouncingScrollPhysics(),
                                padding: EdgeInsets.fromLTRB(
                                  20,
                                  0,
                                  20,
                                  AppBottomNavBar.reservedHeight(context),
                                ),
                                children: [
                                  AccountUserInfoSection(
                                    signingOut: state.isLogoutInProgress,
                                    logoutFreeze: state.logoutUiFreeze,
                                  ),
                                  const SizedBox(height: 16),
                                  AccountMenuSection(
                                    onNotificationsToggle:
                                        _onNotificationsToggle,
                                    onShareProgress:
                                        AccountActions.onShareProgressTap,
                                    onComingSoon: AccountActions.comingSoon,
                                  ),
                                  const SizedBox(height: 18),
                                  AccountLogoutFooter(
                                    actionsEnabled: !sessionBusy,
                                    onLogOutPressed: () =>
                                        _onLogOutPressed(context),
                                  ),
                                  const SizedBox(height: 16),
                                ],
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

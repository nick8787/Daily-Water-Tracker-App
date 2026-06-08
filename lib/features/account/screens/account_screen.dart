import 'package:daily_water_tracker/common/di/injector_module.dart';
import 'package:daily_water_tracker/common/widgets/app_notification_settings_dialog.dart';
import 'package:daily_water_tracker/common/widgets/main_shell_tab_body.dart';
import 'package:daily_water_tracker/data/repositories/firestore_repository.dart';
import 'package:daily_water_tracker/data/repositories/messaging_repository.dart';
import 'package:daily_water_tracker/data/repositories/storage_repository.dart';
import 'package:daily_water_tracker/features/account/account_actions.dart';
import 'package:daily_water_tracker/features/account/cubit/account_cubit.dart';
import 'package:daily_water_tracker/features/account/cubit/account_state.dart';
import 'package:daily_water_tracker/features/account/listeners/account_session_listener.dart';
import 'package:daily_water_tracker/features/account/widgets/account_app_bar.dart';
import 'package:daily_water_tracker/features/account/widgets/account_menu_section.dart';
import 'package:daily_water_tracker/features/account/widgets/account_user_info_section.dart';
import 'package:daily_water_tracker/firebase/services/auth_service.dart';
import 'package:daily_water_tracker/firebase/services/local_notifications_service.dart';
import 'package:daily_water_tracker/firebase/services/reminder_scheduler_service.dart';
import 'package:daily_water_tracker/firebase/services/user_account_deletion_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  Future<void> _onNotificationsToggle(BuildContext context, bool wantOn) async {
    final cubit = context.read<AccountCubit>();
    final blocked = await cubit.setAppNotificationsEnabled(wantOn);
    if (!context.mounted) return;
    if (blocked) {
      await showNotificationSettingsDialog(context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AccountLifecycleSync(
      child: AccountSessionListener(
        child: BlocBuilder<AccountCubit, AccountState>(
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
                                signingOut: state.isLogoutInProgress,
                                logoutFreeze: state.logoutUiFreeze,
                                onNotificationsToggle: _onNotificationsToggle,
                                onShareProgress: AccountActions.onShareProgressTap,
                                onComingSoon: AccountActions.comingSoon,
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
      ),
    );
  }
}

/// Menu card grows on tall screens; fixed gaps keep profile/nav spacing tight.
class _AccountScrollableBody extends StatelessWidget {
  const _AccountScrollableBody({
    required this.signingOut,
    required this.logoutFreeze,
    required this.onNotificationsToggle,
    required this.onShareProgress,
    required this.onComingSoon,
  });

  final bool signingOut;
  final AccountLogoutUiFreeze? logoutFreeze;
  final void Function(BuildContext context, bool value) onNotificationsToggle;
  final Future<void> Function(BuildContext context) onShareProgress;
  final void Function(BuildContext context, String feature) onComingSoon;

  static const double _horizontalPadding = 20;
  static const double _sectionGap = 16;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: MainShellTabBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AccountUserInfoSection(
              signingOut: signingOut,
              logoutFreeze: logoutFreeze,
            ),
            const SizedBox(height: _sectionGap),
            Expanded(
              child: AccountMenuSection(
                expandVertically: true,
                onNotificationsToggle: onNotificationsToggle,
                onShareProgress: onShareProgress,
                onComingSoon: onComingSoon,
              ),
            ),
          ],
        ),
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

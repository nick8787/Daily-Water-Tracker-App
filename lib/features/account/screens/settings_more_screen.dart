import 'package:daily_water_tracker/common/assets.dart';
import 'package:daily_water_tracker/common/router.dart';
import 'package:daily_water_tracker/features/account/account_actions.dart';
import 'package:daily_water_tracker/features/account/account_language_actions.dart';
import 'package:daily_water_tracker/features/account/cubit/account_cubit.dart';
import 'package:daily_water_tracker/features/account/widgets/account_logout_footer.dart';
import 'package:daily_water_tracker/features/account/widgets/account_menu_card.dart';
import 'package:daily_water_tracker/features/account/widgets/account_menu_item.dart';
import 'package:daily_water_tracker/features/locale/widgets/locale_rebuild.dart';
import 'package:daily_water_tracker/features/theme/theme.dart';
import 'package:daily_water_tracker/features/vibration/cubit/vibration_cubit.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../common/widgets/app_screen_title.dart';
import '../widgets/account_menu_divider.dart';

class SettingsMoreScreen extends StatelessWidget {
  const SettingsMoreScreen({super.key});

  static const double _logoutTopGap = 16;

  @override
  Widget build(BuildContext context) {
    return LocaleRebuild(
      builder: (context) => const _SettingsMoreView(),
    );
  }
}

class _SettingsMoreView extends StatelessWidget {
  const _SettingsMoreView();

  @override
  Widget build(BuildContext context) {
    final sessionBusy = context.select<AccountCubit, bool>(
      (c) => c.state.isSessionActionInProgress,
    );
    final vibrationEnabled = context.select<VibrationCubit, bool>(
      (c) => c.state.enabled,
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        centerTitle: true,
        title: AppScreenTitle.appBarLocalized(
          localeKey: LocaleKeys.account_menu_more,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        children: [
          AccountMenuCard(
            children: [
              AccountMenuItem(
                leadingAsset: icProfileSecurity,
                title: LocaleKeys.account_menu_login_security.tr(),
                hapticOnTap: true,
                onTap: () => context.push(loginSecurityRoute),
              ),
              const AccountMenuDivider(),
              AccountMenuItem(
                leadingIcon: Icons.language_rounded,
                title: LocaleKeys.account_menu_language.tr(),
                hapticOnTap: true,
                onTap: () => AccountLanguageActions.onLanguageTap(context),
              ),
              const AccountMenuDivider(),
              AccountMenuItem(
                leadingIcon: Icons.vibration_rounded,
                title: LocaleKeys.account_menu_use_vibration.tr(),
                showChevron: false,
                trailing: CupertinoSwitch(
                  value: vibrationEnabled,
                  activeTrackColor: brandBlue,
                  onChanged: (value) =>
                      context.read<VibrationCubit>().setEnabled(value),
                ),
                onTap: () => context.read<VibrationCubit>().setEnabled(
                  !vibrationEnabled,
                ),
              ),
            ],
          ),
          const SizedBox(height: SettingsMoreScreen._logoutTopGap),
          AccountLogoutFooter(
            actionsEnabled: !sessionBusy,
            onLogOutPressed: () => AccountActions.confirmAndLogOut(context),
          ),
        ],
      ),
    );
  }
}

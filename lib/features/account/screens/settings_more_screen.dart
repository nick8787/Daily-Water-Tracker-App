import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_water_tracker/common/assets.dart';
import 'package:daily_water_tracker/features/account/account_actions.dart';
import 'package:daily_water_tracker/features/account/cubit/account_cubit.dart';
import 'package:daily_water_tracker/features/account/widgets/account_logout_footer.dart';
import 'package:daily_water_tracker/features/account/widgets/account_menu_card.dart';
import 'package:daily_water_tracker/features/account/widgets/account_menu_item.dart';

import '../../../common/widgets/app_screen_title.dart';

class SettingsMoreScreen extends StatelessWidget {
  const SettingsMoreScreen({super.key});

  static const double _logoutTopGap = 16;

  @override
  Widget build(BuildContext context) {
    final sessionBusy = context.select<AccountCubit, bool>(
      (c) => c.state.isSessionActionInProgress,
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
                onTap: () => AccountActions.comingSoon(
                  context,
                  LocaleKeys.account_menu_login_security.tr(),
                ),
              ),
            ],
          ),
          const SizedBox(height: _logoutTopGap),
          AccountLogoutFooter(
            actionsEnabled: !sessionBusy,
            onLogOutPressed: () => AccountActions.confirmAndLogOut(context),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:daily_water_tracker/common/assets.dart';
import 'package:daily_water_tracker/features/account/widgets/account_menu_card.dart';
import 'package:daily_water_tracker/features/account/widgets/account_menu_item.dart';
import 'package:daily_water_tracker/features/account/account_actions.dart';

import '../../../common/widgets/app_screen_title.dart';
import '../widgets/account_menu_divider.dart';

class SettingsMoreScreen extends StatelessWidget {
  const SettingsMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          // ready-made card widget
          AccountMenuCard(
            children: [
              AccountMenuItem(
                leadingAsset: icPrivacyPolicy,
                title: LocaleKeys.account_menu_privacy_policy.tr(),
                onTap: () => AccountActions.comingSoon(
                  context,
                  LocaleKeys.account_menu_privacy_policy.tr(),
                ),
              ),
              const AccountMenuDivider(),
              AccountMenuItem(
                leadingAsset: icProfileSecurity,
                title: LocaleKeys.account_menu_login_security.tr(),
                onTap: () => AccountActions.comingSoon(
                  context,
                  LocaleKeys.account_menu_login_security.tr(),
                ),
              ),
              // next item via AccountMenuDivider
            ],
          ),
        ],
      ),
    );
  }
}
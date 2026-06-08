import 'package:daily_water_tracker/common/di/injector_module.dart';
import 'package:daily_water_tracker/common/router.dart';
import 'package:daily_water_tracker/common/widgets/app_screen_title.dart';
import 'package:daily_water_tracker/common/widgets/app_snackbar.dart';
import 'package:daily_water_tracker/features/account/widgets/account_menu_card.dart';
import 'package:daily_water_tracker/features/account/widgets/account_menu_item.dart';
import 'package:daily_water_tracker/firebase/services/auth_service.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginSecurityScreen extends StatelessWidget {
  const LoginSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        centerTitle: true,
        title: AppScreenTitle.appBarLocalized(
          localeKey: LocaleKeys.login_security_title,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        children: [
          AccountMenuCard(
            children: [
              AccountMenuItem(
                leadingIcon: Icons.lock_outline,
                title: LocaleKeys.login_security_change_password.tr(),
                onTap: () => _onChangePasswordTap(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onChangePasswordTap(BuildContext context) {
    final authService = InjectorModule.locator<AuthService>();
    if (!authService.currentUserHasPasswordProvider) {
      AppSnackBar.showInfo(
        context,
        title: LocaleKeys.login_security_snackbar_email_only_title.tr(),
        message: LocaleKeys.login_security_snackbar_email_only.tr(),
      );
      return;
    }

    context.push(changePasswordRoute);
  }
}

import 'package:daily_water_tracker/common/assets.dart';
import 'package:daily_water_tracker/common/router.dart';
import 'package:daily_water_tracker/features/account/cubit/account_cubit.dart';
import 'package:daily_water_tracker/features/account/widgets/account_menu_card.dart';
import 'package:daily_water_tracker/features/account/widgets/account_menu_divider.dart';
import 'package:daily_water_tracker/features/account/widgets/account_menu_item.dart';
import 'package:daily_water_tracker/features/home/cubit/home_cubit.dart';
import 'package:daily_water_tracker/features/legal/widgets/privacy_policy_sheet.dart';
import 'package:daily_water_tracker/features/theme/theme.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AccountMenuSection extends StatelessWidget {
  const AccountMenuSection({
    super.key,
    required this.onNotificationsToggle,
    required this.onShareProgress,
    required this.onComingSoon,
    this.expandVertically = false,
  });

  final void Function(BuildContext context, bool value) onNotificationsToggle;
  final Future<void> Function(BuildContext context) onShareProgress;
  final void Function(BuildContext context, String feature) onComingSoon;
  final bool expandVertically;

  Widget _menuRow(Widget child) {
    if (!expandVertically) return child;
    return Expanded(child: child);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeBloc = context.read<ThemeBloc>();

    void onDarkThemeToggle(bool enabled) =>
        themeBloc.setDarkThemeEnabled(enabled);

    return AccountMenuCard(
      expandVertically: expandVertically,
      children: [
        _menuRow(AccountMenuItem(
          fillVertically: expandVertically,
          leadingAsset: icUserProfile,
          title: LocaleKeys.account_menu_my_profile.tr(),
          hapticOnTap: true,
          onTap: () => context.push(profileRoute),
        )),
        const AccountMenuDivider(),
        _menuRow(AccountMenuItem(
          fillVertically: expandVertically,
          leadingAsset: icUserPreferences,
          title: LocaleKeys.account_menu_preferences.tr(),
          hapticOnTap: true,
          onTap: () => context.push(preferencesRoute),
        )),
        const AccountMenuDivider(),
        _menuRow(AccountMenuItem(
          fillVertically: expandVertically,
          leadingAsset: icUserHistory,
          title: LocaleKeys.account_menu_history.tr(),
          hapticOnTap: true,
          onTap: () =>
              context.push(historyRoute, extra: context.read<HomeCubit>()),
        )),
        const AccountMenuDivider(),
        _menuRow(AccountMenuItem(
          fillVertically: expandVertically,
          leadingIcon: Icons.emoji_events_outlined,
          title: LocaleKeys.account_menu_achievements.tr(),
          hapticOnTap: true,
          onTap: () => context.push(achievementsRoute),
        )),
        const AccountMenuDivider(),
        _menuRow(AccountMenuItem(
          fillVertically: expandVertically,
          leadingAsset: icAccountNotifications,
          title: LocaleKeys.account_menu_notifications.tr(),
          showChevron: false,
          enabled: !context
              .select<AccountCubit, bool>(
                (c) => c.state.isNotificationPermissionBusy,
              ),
          trailing: Builder(
            builder: (context) {
              final acc = context.watch<AccountCubit>().state;
              final busy = acc.isNotificationPermissionBusy;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (busy)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CupertinoActivityIndicator(),
                      ),
                    ),
                  CupertinoSwitch(
                    value: acc.isNotificationsEnabled,
                    activeTrackColor: brandBlue,
                    onChanged: busy
                        ? null
                        : (v) => onNotificationsToggle(context, v),
                  ),
                ],
              );
            },
          ),
          onTap: () {
            final acc = context.read<AccountCubit>().state;
            if (acc.isNotificationPermissionBusy) return;
            onNotificationsToggle(context, !acc.isNotificationsEnabled);
          },
        )),
        const AccountMenuDivider(),
        _menuRow(AccountMenuItem(
          fillVertically: expandVertically,
          leadingAsset: icShareMyProgress,
          title: LocaleKeys.account_menu_share_progress.tr(),
          hapticOnTap: true,
          onTap: () => onShareProgress(context),
        )),
        const AccountMenuDivider(),
        _menuRow(AccountMenuItem(
          fillVertically: expandVertically,
          leadingIcon: Icons.dark_mode_outlined,
          title: LocaleKeys.account_menu_dark_theme.tr(),
          showChevron: false,
          trailing: CupertinoSwitch(
            value: isDark,
            activeTrackColor: brandBlue,
            onChanged: onDarkThemeToggle,
          ),
          onTap: () => onDarkThemeToggle(!isDark),
        )),
        const AccountMenuDivider(),
        _menuRow(AccountMenuItem(
          fillVertically: expandVertically,
          leadingAsset: icPrivacyPolicy,
          title: LocaleKeys.account_menu_privacy_policy.tr(),
          onTap: () => showPrivacyPolicySheet(context),
        )),
        const AccountMenuDivider(),
        _menuRow(AccountMenuItem(
          fillVertically: expandVertically,
          leadingIcon: Icons.more_horiz,
          title: LocaleKeys.account_menu_more.tr(),
          hapticOnTap: true,
          onTap: () => context.push(
            settingsMoreRoute,
            extra: context.read<AccountCubit>(),
          ),
        )),
      ],
    );
  }
}

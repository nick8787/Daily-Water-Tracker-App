import 'package:daily_water_tracker/common/services/app_language_settings_service.dart';
import 'package:daily_water_tracker/common/widgets/app_bottom_sheet.dart';
import 'package:daily_water_tracker/features/locale/cubit/locale_cubit.dart';
import 'package:daily_water_tracker/features/locale/cubit/locale_state.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract final class AccountLanguageActions {
  AccountLanguageActions._();

  static Future<void> onLanguageTap(BuildContext context) async {
    context.read<LocaleCubit>().useSystemLocale();

    if (kIsWeb) {
      await _showInAppLanguageSheet(context);
      return;
    }

    final opened = await AppLanguageSettingsService.open();
    if (!opened && context.mounted) {
      await _showInAppLanguageSheet(context);
    }
  }

  static Future<void> _showInAppLanguageSheet(BuildContext context) async {
    final cubit = context.read<LocaleCubit>();
    final preference = cubit.state.preference;

    await showAppBottomSheet<void>(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBottomSheetTitle(LocaleKeys.account_menu_language.tr()),
          AppBottomSheetAction(
            icon: Icons.language_rounded,
            title: LocaleKeys.account_language_option_english.tr(),
            onTap: () {
              Navigator.of(context).pop();
              cubit.useEnglish();
            },
          ),
          AppBottomSheetAction(
            icon: Icons.translate_rounded,
            title: LocaleKeys.account_language_option_ukrainian.tr(),
            onTap: () {
              Navigator.of(context).pop();
              cubit.useUkrainian();
            },
          ),
          AppBottomSheetAction(
            icon: Icons.settings_suggest_outlined,
            title: LocaleKeys.account_language_option_system.tr(),
            onTap: () {
              Navigator.of(context).pop();
              cubit.useSystemLocale();
            },
          ),
          if (preference != AppLocalePreference.system) const SizedBox(height: 8),
        ],
      ),
    );
  }
}

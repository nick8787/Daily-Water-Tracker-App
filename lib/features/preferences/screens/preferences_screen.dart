import 'dart:async';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_water_tracker/common/di/injector_module.dart';
import 'package:daily_water_tracker/common/router.dart';
import 'package:daily_water_tracker/common/widgets/app_loader.dart';
import 'package:daily_water_tracker/common/widgets/dismiss_keyboard_on_tap.dart';
import 'package:daily_water_tracker/common/widgets/app_primary_button.dart';
import 'package:daily_water_tracker/common/widgets/app_screen_title.dart';
import 'package:daily_water_tracker/common/widgets/app_snackbar.dart';
import 'package:daily_water_tracker/features/preferences/cubit/preferences_cubit.dart';
import 'package:daily_water_tracker/features/preferences/cubit/preferences_state.dart';
import 'package:daily_water_tracker/features/preferences/widgets/daily_goal_section.dart';
import 'package:daily_water_tracker/features/preferences/widgets/drink_presets_section.dart';
import 'package:daily_water_tracker/features/preferences/widgets/reminder_settings_section.dart';
import 'package:daily_water_tracker/firebase/services/auth_service.dart';
import 'package:daily_water_tracker/data/repositories/firestore_repository.dart';
import 'package:daily_water_tracker/firebase/services/reminder_scheduler_service.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _wasSaving = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PreferencesCubit(
        authService: InjectorModule.locator<AuthService>(),
        firestoreRepository: context.read<FirestoreRepository>(),
        reminderScheduler: context.read<ReminderSchedulerService>(),
      )..initialize(),
      child: BlocConsumer<PreferencesCubit, PreferencesState>(
        listener: (context, state) {
          if (state is PreferencesLoaded) {
            unawaited(_onPreferencesLoaded(context, state));
          }
        },
        builder: (context, state) {
          final loaded = state is PreferencesLoaded ? state : null;

          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              centerTitle: true,
              title: AppScreenTitle.appBarLocalized(
                localeKey: LocaleKeys.preferences_title,
              ),
            ),
            body: SafeArea(
              child: DismissKeyboardOnTap(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                    children: [
                      if (loaded == null) ...[
                        const SizedBox(height: 40),
                        const Center(child: CircularProgressIndicator()),
                      ] else ...[
                        DailyGoalSection(
                          dailyGoalMl: loaded.dailyGoalMlDraft,
                          isAutoGoalDraft: loaded.isAutoGoalDraft,
                          onGoalMlChanged: context
                              .read<PreferencesCubit>()
                              .setDailyGoalMl,
                          onAutoGoalChanged: context
                              .read<PreferencesCubit>()
                              .setAutoGoalEnabled,
                        ),
                        const SizedBox(height: 14),
                        const DrinkPresetsSection(),
                        const SizedBox(height: 14),
                        const ReminderSettingsSection(),
                        const SizedBox(height: 18),
                        AppGradientButton(
                          label: LocaleKeys.preferences_button_save.tr(),
                          enabled: !loaded.isSaving,
                          busy: loaded.isSaving,
                          onTap: () => context.read<PreferencesCubit>().save(),
                        ),
                      ],
                    ],
                  ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _onPreferencesLoaded(
    BuildContext context,
    PreferencesLoaded state,
  ) async {
    final justFinished = _wasSaving && !state.isSaving;
    _wasSaving = state.isSaving;

    if (state.isSaving) {
      AppLoader.show(context, message: LocaleKeys.loader_saving.tr());
    } else if (AppLoader.isShowing) {
      await AppLoader.hideWithMinimumVisibleDuration();
    }
    if (!context.mounted) return;

    if (state.snackMessage != null) {
      AppSnackBar.showInfo(
        context,
        title: LocaleKeys.preferences_snackbar_title.tr(),
        message: state.snackMessage!,
      );
      context.read<PreferencesCubit>().clearSnackMessage();
    }

    if (state.errorMessage != null) {
      AppSnackBar.showError(context, state.errorMessage!.tr());
    }

    if (justFinished && state.errorMessage == null && context.mounted) {
      Navigator.of(context).pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final snackContext = rootNavigatorKey.currentContext;
        if (snackContext == null) return;
        AppSnackBar.showSuccess(
          snackContext,
          title: LocaleKeys.preferences_snackbar_saved_title.tr(),
          message: LocaleKeys.preferences_snackbar_saved_message.tr(),
          dismissAfter: const Duration(seconds: 3),
        );
      });
    }
  }
}

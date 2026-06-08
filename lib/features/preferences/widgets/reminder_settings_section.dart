import 'package:daily_water_tracker/common/services/app_bootstrapper.dart';
import 'package:daily_water_tracker/features/preferences/cubit/preferences_cubit.dart';
import 'package:daily_water_tracker/features/preferences/cubit/preferences_state.dart';
import 'package:daily_water_tracker/features/preferences/preferences_constants.dart';
import 'package:daily_water_tracker/features/preferences/utils/quiet_hours_format.dart';
import 'package:daily_water_tracker/features/preferences/widgets/info_sheets/reminders_info_sheet.dart';
import 'package:daily_water_tracker/features/preferences/widgets/preferences_info_bottom_sheet.dart';
import 'package:daily_water_tracker/features/preferences/widgets/preferences_section_shell.dart';
import 'package:daily_water_tracker/features/theme/theme_info.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReminderSettingsSection extends StatelessWidget {
  const ReminderSettingsSection({super.key});

  static int? _hourlyDropdownValue(int? raw) {
    if (raw == null || raw <= 0) return null;
    if (raw >= 1 && raw <= 4) return raw;
    return null;
  }

  static int? _dropdownValue(PreferencesLoaded state) {
    if (flutterFlavor.isDev &&
        state.reminderIntervalMinutesDraft == kDebugReminderIntervalMinutes) {
      return kReminderDropdownDebugThreeMinutes;
    }
    return _hourlyDropdownValue(state.reminderIntervalDraft);
  }

  static Future<void> _pickStart(
    BuildContext context,
    PreferencesLoaded loaded,
  ) async {
    final cubit = context.read<PreferencesCubit>();
    final initial = parseQuietHours(
      loaded.quietHoursStartDraft ?? loaded.profile.quietHoursStart,
      const TimeOfDay(hour: 22, minute: 0),
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: brandBlue),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null && context.mounted) {
      cubit.setQuietHoursStart(formatQuietHours(picked));
    }
  }

  static Future<void> _pickEnd(
    BuildContext context,
    PreferencesLoaded loaded,
  ) async {
    final cubit = context.read<PreferencesCubit>();
    final initial = parseQuietHours(
      loaded.quietHoursEndDraft ?? loaded.profile.quietHoursEnd,
      const TimeOfDay(hour: 8, minute: 0),
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: brandBlue),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null && context.mounted) {
      cubit.setQuietHoursEnd(formatQuietHours(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<PreferencesCubit, PreferencesState>(
      builder: (context, state) {
        if (state is! PreferencesLoaded) {
          return const SizedBox.shrink();
        }

        final ddValue = _dropdownValue(state);
        final remindersOn = ddValue != null;

        final startLabel =
            state.quietHoursStartDraft ??
            state.profile.quietHoursStart ??
            '22:00';
        final endLabel =
            state.quietHoursEndDraft ?? state.profile.quietHoursEnd ?? '08:00';

        return PreferencesSectionShell(
          title: LocaleKeys.preferences_section_reminders.tr(),
          onInfoTap: () => showPreferencesInfoSheet(
            context,
            body: const RemindersInfoSheet(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                LocaleKeys.preferences_reminders_hint.tr(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 14),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: LocaleKeys.preferences_reminders_interval_label.tr(),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  filled: true,
                  fillColor: AppFieldStyle.fillColor(context),
                  border: AppFieldStyle.borderNone(),
                  enabledBorder: AppFieldStyle.borderEnabled(),
                  focusedBorder: AppFieldStyle.borderFocused(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    value: ddValue,
                    isExpanded: true,
                    items: [
                      DropdownMenuItem<int?>(
                        child: Text(LocaleKeys.preferences_reminders_off.tr()),
                      ),
                      DropdownMenuItem<int?>(
                        value: 1,
                        child: Text(LocaleKeys.preferences_reminders_every_1h.tr()),
                      ),
                      DropdownMenuItem<int?>(
                        value: 2,
                        child: Text(LocaleKeys.preferences_reminders_every_2h.tr()),
                      ),
                      DropdownMenuItem<int?>(
                        value: 3,
                        child: Text(LocaleKeys.preferences_reminders_every_3h.tr()),
                      ),
                      DropdownMenuItem<int?>(
                        value: 4,
                        child: Text(LocaleKeys.preferences_reminders_every_4h.tr()),
                      ),
                      if (flutterFlavor.isDev)
                        DropdownMenuItem<int?>(
                          value: kReminderDropdownDebugThreeMinutes,
                          child: Text(LocaleKeys.preferences_reminders_debug_3min.tr()),
                        ),
                    ],
                    onChanged: (v) =>
                        context.read<PreferencesCubit>().setReminderInterval(v),
                  ),
                ),
              ),
              if (remindersOn) ...[
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    LocaleKeys.preferences_reminders_quiet_hours.tr(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _QuietTimeCard(
                        label: LocaleKeys.preferences_reminders_from.tr(),
                        value: startLabel,
                        onTap: () => _pickStart(context, state),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuietTimeCard(
                        label: LocaleKeys.preferences_reminders_to.tr(),
                        value: endLabel,
                        onTap: () => _pickEnd(context, state),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _QuietTimeCard extends StatelessWidget {
  const _QuietTimeCard({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: AppFieldStyle.fillColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppFieldStyle.enabledBorderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

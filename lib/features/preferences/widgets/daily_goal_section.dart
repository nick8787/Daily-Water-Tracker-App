import 'package:daily_water_tracker/features/preferences/preferences_constants.dart';
import 'package:daily_water_tracker/features/preferences/widgets/info_sheets/goal_info_sheet.dart';
import 'package:daily_water_tracker/features/preferences/widgets/preferences_info_bottom_sheet.dart';
import 'package:daily_water_tracker/features/preferences/widgets/preferences_section_shell.dart';
import 'package:daily_water_tracker/features/theme/theme_info.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DailyGoalSection extends StatelessWidget {
  const DailyGoalSection({
    super.key,
    required this.dailyGoalMl,
    required this.isAutoGoalDraft,
    required this.onGoalMlChanged,
    required this.onAutoGoalChanged,
  });

  final int dailyGoalMl;
  final bool isAutoGoalDraft;
  final ValueChanged<int> onGoalMlChanged;
  final ValueChanged<bool> onAutoGoalChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clamped = dailyGoalMl.clamp(kDailyGoalMinMl, kDailyGoalMaxMl);
    const divisions = (kDailyGoalMaxMl - kDailyGoalMinMl) ~/ kDailyGoalStepMl;

    return PreferencesSectionShell(
      title: LocaleKeys.preferences_section_goal.tr(),
      onInfoTap: () => showPreferencesInfoSheet(
        context,
        body: const GoalInfoSheet(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            LocaleKeys.preferences_goal_value_ml.tr(namedArgs: {'value': '$clamped'}),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            LocaleKeys.preferences_goal_hint.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 18),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 5,
              activeTrackColor: brandBlue,
              inactiveTrackColor: brandBlue.withValues(alpha: 0.22),
              thumbColor: white,
              overlayColor: brandBlue.withValues(alpha: 0.16),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 13),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 22),
            ),
            child: Slider(
              min: kDailyGoalMinMl.toDouble(),
              max: kDailyGoalMaxMl.toDouble(),
              divisions: divisions,
              value: clamped.toDouble(),
              label: LocaleKeys.preferences_goal_value_ml.tr(namedArgs: {'value': '$clamped'}),
              onChanged: isAutoGoalDraft
                  ? null
                  : (v) {
                      onGoalMlChanged(v.round());
                    },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$kDailyGoalMinMl ml',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
                Text(
                  '$kDailyGoalMaxMl ml',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.45,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    LocaleKeys.preferences_goal_auto_toggle.tr(
                      namedArgs: {'mlPerKg': '$kMlPerKgEstimate'},
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                CupertinoSwitch(
                  value: isAutoGoalDraft,
                  activeTrackColor: brandBlue,
                  onChanged: onAutoGoalChanged,
                ),
              ],
            ),
          ),
          if (isAutoGoalDraft) ...[
            const SizedBox(height: 10),
            Text(
              LocaleKeys.preferences_goal_auto_hint.tr(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.52),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

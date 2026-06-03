import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

import 'package:daily_water_tracker/features/home/widgets/water_progress_indicator.dart';
import 'package:daily_water_tracker/features/theme/theme_info.dart';

class GoalInfoSheet extends StatelessWidget {
  const GoalInfoSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    const graphite = WaterProgressIndicator.valueGraphite;
    const muted = WaterProgressIndicator.labelMuted;
    final tint = brandBlue.withValues(alpha: 0.14);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.water_drop_outlined,
              size: 28,
              color: brandBlue.withValues(alpha: 0.9),
            ),
            const SizedBox(width: 8),
            Text(
              LocaleKeys.preferences_info_goal_title.tr(),
              textAlign: TextAlign.center,
              style: theme.titleLarge?.copyWith(
                color: graphite,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.35,
                height: 1.15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          LocaleKeys.preferences_info_goal_why_title.tr(),
          style: theme.titleSmall?.copyWith(
            color: graphite,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          LocaleKeys.preferences_info_goal_why_body.tr(),
          style: theme.bodyMedium?.copyWith(
            color: graphite,
            height: 1.45,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.monitor_weight_outlined,
                    size: 22,
                    color: brandBlue.withValues(alpha: 0.95),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      LocaleKeys.preferences_info_goal_auto_title.tr(),
                      style: theme.titleSmall?.copyWith(
                        color: graphite,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  style: theme.bodyMedium?.copyWith(
                    color: graphite,
                    height: 1.45,
                  ),
                  children: [
                    TextSpan(
                      text: LocaleKeys.preferences_info_goal_auto_prefix.tr(),
                    ),
                    TextSpan(
                      text: LocaleKeys.preferences_info_goal_auto_formula.tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: brandBlue,
                      ),
                    ),
                    TextSpan(
                      text: LocaleKeys.preferences_info_goal_auto_suffix.tr(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 22,
              color: muted.withValues(alpha: 0.95),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: theme.bodyMedium?.copyWith(
                    color: graphite,
                    height: 1.45,
                  ),
                  children: [
                    TextSpan(
                      text: LocaleKeys.preferences_info_goal_control_bold.tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: graphite,
                      ),
                    ),
                    TextSpan(
                      text: LocaleKeys.preferences_info_goal_control_body.tr(),
                      style: TextStyle(
                        color: graphite,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

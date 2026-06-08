import 'package:daily_water_tracker/features/home/widgets/water_progress_indicator.dart';
import 'package:daily_water_tracker/features/theme/theme_info.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class RemindersInfoSheet extends StatelessWidget {
  const RemindersInfoSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    const graphite = WaterProgressIndicator.valueGraphite;
    const muted = WaterProgressIndicator.labelMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_active_outlined,
              size: 28,
              color: brandBlue.withValues(alpha: 0.9),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                LocaleKeys.preferences_info_reminders_title.tr(),
                textAlign: TextAlign.center,
                style: theme.titleLarge?.copyWith(
                  color: graphite,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.35,
                  height: 1.15,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          LocaleKeys.preferences_info_reminders_gentle_title.tr(),
          style: theme.titleSmall?.copyWith(
            color: graphite,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          LocaleKeys.preferences_info_reminders_gentle_body.tr(),
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
            color: brandBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bedtime_outlined,
                    size: 22,
                    color: brandBlue.withValues(alpha: 0.95),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      LocaleKeys.preferences_info_reminders_quiet_title.tr(),
                      style: theme.titleSmall?.copyWith(
                        color: graphite,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                LocaleKeys.preferences_info_reminders_quiet_body.tr(),
                style: theme.bodyMedium?.copyWith(
                  color: graphite,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 22,
              color: muted.withValues(alpha: 0.95),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                LocaleKeys.preferences_info_reminders_quiet_note.tr(),
                style: theme.bodySmall?.copyWith(
                  color: muted,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:daily_water_tracker/features/home/widgets/water_progress_indicator.dart';
import 'package:daily_water_tracker/features/theme/theme_info.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PresetsInfoSheet extends StatelessWidget {
  const PresetsInfoSheet({super.key});

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
              Icons.local_drink_outlined,
              size: 28,
              color: brandBlue.withValues(alpha: 0.9),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                LocaleKeys.preferences_info_presets_title.tr(),
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
          LocaleKeys.preferences_info_presets_quick_title.tr(),
          style: theme.titleSmall?.copyWith(
            color: graphite,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          LocaleKeys.preferences_info_presets_quick_body.tr(),
          style: theme.bodyMedium?.copyWith(
            color: graphite,
            height: 1.45,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.emoji_food_beverage_outlined,
              size: 22,
              color: brandBlue.withValues(alpha: 0.9),
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
                    TextSpan(text: LocaleKeys.preferences_info_presets_tune_prefix.tr()),
                    TextSpan(
                      text: LocaleKeys.preferences_info_presets_tune_bold.tr(),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    TextSpan(
                      text: LocaleKeys.preferences_info_presets_tune_suffix.tr(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.touch_app_outlined,
              size: 22,
              color: muted.withValues(alpha: 0.95),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                LocaleKeys.preferences_info_presets_tip.tr(),
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

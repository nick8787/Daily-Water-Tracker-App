import 'package:daily_water_tracker/features/theme/app_theme_extensions.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class StatisticsSummaryMetricCard extends StatelessWidget {
  const StatisticsSummaryMetricCard({
    super.key,
    required this.leading,
    required this.title,
    required this.hero,
  });

  final Widget leading;
  final String title;
  final Widget hero;

  static BoxDecoration tileDecoration(BuildContext context) =>
      appCardDecoration(context, radius: 24);

  static const EdgeInsets tilePadding = EdgeInsets.all(20);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      height: 1.25,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.44),
    );
    final periodStyle = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w500,
      fontSize: 11,
      height: 1.25,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.32),
    );

    return Container(
      padding: tilePadding,
      decoration: tileDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              leading,
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: titleStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(LocaleKeys.statistics_period_last_7_days.tr(), style: periodStyle),
          const Spacer(),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: hero,
            ),
          ),
        ],
      ),
    );
  }
}

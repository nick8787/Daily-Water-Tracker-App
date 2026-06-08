import 'package:daily_water_tracker/features/statistics/widgets/statistics_summary_metric_card.dart';
import 'package:daily_water_tracker/features/statistics/widgets/weekly_bar_chart.dart';
import 'package:daily_water_tracker/firebase/models/statistics_week_data.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class StatisticsWeeklyActivityCard extends StatelessWidget {
  const StatisticsWeeklyActivityCard({
    super.key,
    required this.weekData,
  });

  final StatisticsWeekData weekData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final footerStyle =
        theme.textTheme.bodySmall?.copyWith(
          fontSize: 12,
          height: 1.35,
          letterSpacing: -0.05,
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.52),
        ) ??
        TextStyle(
          fontSize: 12,
          height: 1.35,
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.52),
        );

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: StatisticsSummaryMetricCard.tilePadding,
      decoration: StatisticsSummaryMetricCard.tileDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.statistics_weekly_activity_title.tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: WeeklyBarChart(
              dayBars: weekData.dayBars,
              goalMl: weekData.dailyGoalMl,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            weekData.dailyGoalMl <= 0
                ? LocaleKeys.statistics_footer_no_goal.tr()
                : LocaleKeys.statistics_footer_default.tr(),
            style: footerStyle,
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}

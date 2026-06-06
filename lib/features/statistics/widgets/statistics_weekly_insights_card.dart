import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

import 'package:daily_water_tracker/common/l10n/date_format_l10n.dart';
import 'package:daily_water_tracker/features/statistics/models/statistics_presentation.dart';
import 'package:daily_water_tracker/features/theme/app_theme_extensions.dart';
import 'package:daily_water_tracker/features/theme/theme_colors.dart';
import 'package:daily_water_tracker/features/statistics/widgets/statistics_summary_metric_card.dart';

class StatisticsWeeklyInsightsCard extends StatelessWidget {
  const StatisticsWeeklyInsightsCard({
    super.key,
    required this.insights,
  });

  final WeeklyInsightsVm insights;

  static const Color _gold = AppPalette.statisticsGold;
  static const Color _ember = AppPalette.statisticsEmber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: -0.2,
    );

    return Container(
      width: double.infinity,
      padding: StatisticsSummaryMetricCard.tilePadding,
      decoration: StatisticsSummaryMetricCard.tileDecoration(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(LocaleKeys.statistics_insights_title.tr(), style: titleStyle),
          const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _InsightTile(
                    icon: Icons.emoji_events_rounded,
                    iconTint: _gold,
                    title: LocaleKeys.statistics_insights_best_day.tr(),
                    primary: insights.bestDayDate == null
                        ? '—'
                        : formatWeekdayLong(
                            insights.bestDayDate!,
                            context.locale.toString(),
                          ),
                    secondary: LocaleKeys.statistics_insights_best_day_subtitle.tr(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InsightTile(
                    icon: Icons.local_fire_department_rounded,
                    iconTint: _ember,
                    title: LocaleKeys.statistics_insights_streak.tr(),
                    primary: _streakPrimary(insights),
                    secondary: _streakSecondary(insights),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _streakPrimary(WeeklyInsightsVm i) {
    if (!i.hasDailyGoal) return LocaleKeys.common_em_dash.tr();
    if (i.streakDays <= 0) return LocaleKeys.statistics_insights_streak_zero.tr();
    return i.streakDays == 1 ? LocaleKeys.statistics_insights_streak_days_one.tr() : LocaleKeys.statistics_insights_streak_days_other.tr(namedArgs: {'count': '${i.streakDays}'});
  }

  static String _streakSecondary(WeeklyInsightsVm i) {
    if (!i.hasDailyGoal) {
      return LocaleKeys.statistics_insights_no_goal.tr();
    }
    if (i.streakDays <= 0) {
      return LocaleKeys.statistics_insights_start_streak.tr();
    }
    return LocaleKeys.statistics_insights_goal_met_today.tr();
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.icon,
    required this.iconTint,
    required this.title,
    required this.primary,
    required this.secondary,
  });

  final IconData icon;
  final Color iconTint;
  final String title;
  final String primary;
  final String secondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final softBg = Color.lerp(
      iconTint,
      context.appColors.cardSurface,
      0.88,
    )!;
    final titleStyle = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
    );
    final primaryStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.35,
      height: 1.15,
    );
    final secondaryStyle = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w500,
      height: 1.35,
      fontSize: 10.5,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.36),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: softBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(11, 11, 11, 9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.appColors.cardSurface.withValues(alpha: 0.72),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 17,
                    color: iconTint.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: titleStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              primary,
              style: primaryStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              secondary,
              style: secondaryStyle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

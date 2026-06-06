import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

import 'package:daily_water_tracker/common/l10n/date_format_l10n.dart';
import 'package:daily_water_tracker/features/home/widgets/water_progress_indicator.dart';
import 'package:daily_water_tracker/features/theme/theme_colors.dart';
import 'package:daily_water_tracker/firebase/models/statistics_week_data.dart';

class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    super.key,
    required this.dayBars,
    required this.goalMl,
  });

  final List<StatisticsDayBar> dayBars;
  final int goalMl;

  static const List<Color> _barGradientColors = [
    WaterProgressIndicator.gradientTailSoft,
    WaterProgressIndicator.gradientMid,
    WaterProgressIndicator.gradientHeadDeep,
  ];

  static const Color _stubGrey = AppPalette.chartStubGrey;
  static const double _barWidth = 18;
  /// Chart Y-axis extends this far above the goal so the GOAL label fits.
  static const double _goalHeadroomRatio = 1.22;
  /// Bars that meet or exceed the goal render only this far above the goal line.
  static const double _barOverGoalRatio = 1.05;
  static const BorderRadius _radius = BorderRadius.vertical(
    top: Radius.circular(8),
  );

  int? _todayBarIndex() {
    final now = DateTime.now();
    for (var i = 0; i < dayBars.length; i++) {
      final d = dayBars[i].date;
      if (d.year == now.year && d.month == now.month && d.day == now.day) {
        return i;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (dayBars.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final localeTag = context.locale.toString();
    final todayIdx = _todayBarIndex();

    final maxBarMl = dayBars.map((e) => e.totalMl).fold<int>(0, math.max);
    final actualGoal = goalMl > 0 ? goalMl : 3000;
    final hasGoal = goalMl > 0;

    // Keep Y-axis anchored to the goal — do not stretch when intake exceeds it.
    final maxY = hasGoal
        ? math.max(actualGoal * _goalHeadroomRatio, 500.0)
        : math.max(maxBarMl * 1.2, 500.0);

    final stubY = maxY * 0.03;
    final visualBarCap = actualGoal * _barOverGoalRatio;

    return BarChart(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuart,
      BarChartData(
        minY: 0,
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        barTouchData: _buildTouchData(),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) => _buildBottomTitle(
                value,
                meta,
                todayIdx,
                theme,
                localeTag,
              ),
            ),
          ),
        ),
        extraLinesData: _buildGoalLine(actualGoal, maxY, theme),
        barGroups: List.generate(
          dayBars.length,
          (i) => _buildBarGroup(
            i,
            dayBars[i],
            i == todayIdx,
            stubY,
            goalY: hasGoal ? actualGoal.toDouble() : 0,
            visualBarCap: hasGoal ? visualBarCap : null,
          ),
        ),
      ),
    );
  }

  BarTouchData _buildTouchData() {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (_) =>
            AppPalette.chartTooltipBackground.withValues(alpha: 0.95),
        tooltipPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        tooltipMargin: 8,
        tooltipBorderRadius: BorderRadius.circular(12),
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final day = dayBars[group.x];
          final ml = day.totalMl;
          final remain = day.goalMl > 0 ? math.max(0, day.goalMl - ml) : 0;

          return BarTooltipItem(
            '$ml ml\n',
            TextStyle(
              color: AppPalette.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
            children: [
              if (remain > 0)
                TextSpan(
                  text: LocaleKeys.statistics_chart_ml_left.tr(namedArgs: {'remain': '$remain'}),
                  style: TextStyle(
                    color: AppPalette.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
              if (remain == 0)
                TextSpan(
                  text: LocaleKeys.statistics_chart_goal_reached.tr(),
                  style: TextStyle(
                    color: AppPalette.chartPositive,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  ExtraLinesData _buildGoalLine(int goal, double maxY, ThemeData theme) {
    if (goal <= 0 || goal > maxY) return const ExtraLinesData();

    final lineMuted = theme.colorScheme.onSurface.withValues(alpha: 0.15);
    final textMuted = theme.colorScheme.onSurface.withValues(alpha: 0.4);

    return ExtraLinesData(
      extraLinesOnTop: false,
      horizontalLines: [
        HorizontalLine(
          y: goal.toDouble(),
          color: lineMuted,
          strokeWidth: 1.5,
          dashArray: const [6, 6],
          label: HorizontalLineLabel(
            show: true,
            alignment: Alignment.topRight,
            padding: const EdgeInsets.only(right: 4, bottom: 6),
            style: theme.textTheme.labelSmall?.copyWith(
              color: textMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
            labelResolver: (_) => LocaleKeys.statistics_chart_goal_label.tr(),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomTitle(
    double value,
    TitleMeta meta,
    int? todayIdx,
    ThemeData theme,
    String localeTag,
  ) {
    final i = value.toInt();
    if (i < 0 || i >= dayBars.length) return const SizedBox.shrink();

    final isToday = i == todayIdx;
    final letter = formatWeekdayChartLetter(dayBars[i].date, localeTag);

    const accentColor = WaterProgressIndicator.gradientHeadDeep;
    final mutedColor = theme.colorScheme.onSurface.withValues(alpha: 0.35);

    return SideTitleWidget(
      meta: meta,
      space: 10,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: isToday
            ? BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              )
            : null,
        child: Text(
          letter,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
            fontSize: 13,
            color: isToday ? accentColor : mutedColor,
          ),
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(
    int index,
    StatisticsDayBar bar,
    bool isToday,
    double stubY, {
    required double goalY,
    required double? visualBarCap,
  }) {
    final ml = bar.totalMl.toDouble();
    final displayY = _visualBarHeight(
      ml: ml,
      stubY: stubY,
      goalY: goalY,
      visualBarCap: visualBarCap,
    );

    final opacity = isToday ? 1.0 : 0.75;

    final gradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: _barGradientColors
          .map((c) => c.withValues(alpha: opacity))
          .toList(),
    );

    if (ml <= 0) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            fromY: 0,
            toY: stubY,
            width: _barWidth,
            color: _stubGrey,
            borderRadius: _radius,
          ),
        ],
      );
    }

    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          fromY: 0,
          toY: displayY,
          width: _barWidth,
          gradient: gradient,
          borderRadius: _radius,
          backDrawRodData: BackgroundBarChartRodData(show: false),
        ),
      ],
    );
  }

  double _visualBarHeight({
    required double ml,
    required double stubY,
    required double goalY,
    required double? visualBarCap,
  }) {
    if (ml <= 0) return stubY;
    if (goalY <= 0 || visualBarCap == null) return ml;
    if (ml >= goalY) return visualBarCap;
    return ml;
  }
}

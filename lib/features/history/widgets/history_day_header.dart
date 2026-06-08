import 'package:daily_water_tracker/features/home/widgets/water_progress_indicator.dart';
import 'package:daily_water_tracker/features/statistics/widgets/statistics_summary_metric_card.dart';
import 'package:flutter/material.dart';

class HistoryDayHeader extends StatelessWidget {
  const HistoryDayHeader({
    super.key,
    required this.title,
    required this.totalEffectiveMl,
    required this.dailyGoalMl,
  });

  final String title;
  final int totalEffectiveMl;
  final int dailyGoalMl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const labelMuted = WaterProgressIndicator.labelMuted;

    final titleStyle =
        theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: -0.25,
        ) ??
        const TextStyle(fontWeight: FontWeight.w900, fontSize: 18);

    final softStyle =
        theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.12,
          color: labelMuted,
          height: 1.2,
        ) ??
        const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: labelMuted,
          height: 1.2,
        );

    final emphasisStyle = softStyle.copyWith(fontWeight: FontWeight.w800);

    Widget progressText() {
      if (dailyGoalMl <= 0) {
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '$totalEffectiveMl', style: emphasisStyle),
              TextSpan(text: ' ml', style: softStyle),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.right,
        );
      }
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$totalEffectiveMl', style: emphasisStyle),
            TextSpan(text: ' / ', style: softStyle),
            TextSpan(text: '$dailyGoalMl', style: emphasisStyle),
            TextSpan(text: ' ml', style: softStyle),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.right,
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: StatisticsSummaryMetricCard.tilePadding.left,
        right: StatisticsSummaryMetricCard.tilePadding.right,
        bottom: 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(title, style: titleStyle),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: progressText(),
            ),
          ),
        ],
      ),
    );
  }
}

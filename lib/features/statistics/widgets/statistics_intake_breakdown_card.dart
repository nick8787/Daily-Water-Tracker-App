import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_water_tracker/common/l10n/drink_type_l10n.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

import 'package:daily_water_tracker/features/home/widgets/drink_type_svgs.dart';
import 'package:daily_water_tracker/features/home/widgets/water_sheet_shared.dart';
import 'package:daily_water_tracker/features/statistics/models/statistics_presentation.dart';
import 'package:daily_water_tracker/features/statistics/widgets/statistics_summary_metric_card.dart';
import 'package:flutter_svg/flutter_svg.dart';

const double _kBreakdownIcon = 24;
const double _kBarHeight = 6;

class StatisticsIntakeBreakdownCard extends StatelessWidget {
  const StatisticsIntakeBreakdownCard({
    super.key,
    required this.rows,
  });

  final List<IntakeBreakdownRowVm> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: -0.2,
    );
    final captionStyle = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w500,
      fontSize: 11,
      height: 1.25,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.36),
    );
    final nameStyle =
        theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.15,
        ) ??
        const TextStyle(fontWeight: FontWeight.w700, fontSize: 14);
    final pctStyle =
        theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
        ) ??
        TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 14,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
        );

    return Container(
      width: double.infinity,
      padding: StatisticsSummaryMetricCard.tilePadding,
      decoration: StatisticsSummaryMetricCard.tileDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(LocaleKeys.statistics_breakdown_title.tr(), style: titleStyle),
          const SizedBox(height: 4),
          Text(LocaleKeys.statistics_breakdown_caption.tr(), style: captionStyle),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                LocaleKeys.statistics_breakdown_empty.tr(),
                style: theme.textTheme.bodySmall?.copyWith(
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.42),
                ),
              ),
            )
          else
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) const SizedBox(height: 11),
              _BreakdownRow(
                row: rows[i],
                nameStyle: nameStyle,
                pctStyle: pctStyle,
              ),
            ],
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.row,
    required this.nameStyle,
    required this.pctStyle,
  });

  final IntakeBreakdownRowVm row;
  final TextStyle nameStyle;
  final TextStyle pctStyle;

  @override
  Widget build(BuildContext context) {
    final lineColor = waterSheetHydrationLineColor(row.drinkType);
    final track = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              drinkTypeRowSvgAsset(row.drinkType),
              width: _kBreakdownIcon,
              height: _kBreakdownIcon,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                row.drinkType.localizedLabel,
                style: nameStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            Text('${row.percent}%', style: pctStyle),
          ],
        ),
        const SizedBox(height: 7),
        LayoutBuilder(
          builder: (context, c) {
            final w = (c.maxWidth * row.share01).clamp(0.0, c.maxWidth);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: _kBarHeight,
                  width: c.maxWidth,
                  decoration: BoxDecoration(
                    color: track,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  height: _kBarHeight,
                  width: w,
                  decoration: BoxDecoration(
                    color: lineColor,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: lineColor.withValues(alpha: 0.28),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

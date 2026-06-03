import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_water_tracker/common/l10n/drink_type_l10n.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

import 'package:daily_water_tracker/features/home/widgets/drink_type_svgs.dart';
import 'package:daily_water_tracker/features/home/widgets/water_progress_indicator.dart';
import 'package:daily_water_tracker/firebase/models/water_record_model.dart';
import 'package:flutter_svg/flutter_svg.dart';

const double kHydrationDrinkRowSvgSize = 28;

class HydrationDrinkRow extends StatelessWidget {
  const HydrationDrinkRow({
    super.key,
    required this.record,
    required this.timeLabel,
    required this.coeffLabel,
    required this.onTap,
    this.trailing,
    this.mutedColor,
    this.rowPadding = const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
    this.gapAfterIcon = 8,
    this.gapBeforeVolume = 12,
  });

  final WaterRecordModel record;
  final String timeLabel;
  final String coeffLabel;
  final VoidCallback onTap;
  final Widget? trailing;

  final Color? mutedColor;

  final EdgeInsetsGeometry rowPadding;

  final double gapAfterIcon;

  final double gapBeforeVolume;

  static Color defaultMuted(ColorScheme scheme) =>
      WaterProgressIndicator.labelMuted.withValues(alpha: 0.95);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = mutedColor ?? defaultMuted(scheme);
    final titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: -0.15,
    );
    final subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: muted,
      height: 1.2,
      fontWeight: FontWeight.w500,
    );
    final volumeStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: -0.1,
    );
    final coeffStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: muted,
      height: 1.15,
      fontWeight: FontWeight.w500,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: rowPadding,
          child: Row(
            children: [
              SizedBox(
                width: kHydrationDrinkRowSvgSize,
                height: kHydrationDrinkRowSvgSize,
                child: SvgPicture.asset(
                  drinkTypeRowSvgAsset(record.drinkType),
                  excludeFromSemantics: true,
                ),
              ),
              SizedBox(width: gapAfterIcon),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      record.drinkType.localizedLabel,
                      style: titleStyle?.copyWith(color: scheme.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      timeLabel,
                      style: subtitleStyle,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              SizedBox(width: gapBeforeVolume),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${record.volumeMl} ml',
                    textAlign: TextAlign.right,
                    style: volumeStyle?.copyWith(color: scheme.onSurface),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    LocaleKeys.home_row_coefficient.tr(namedArgs: {'value': coeffLabel}),
                    style: coeffStyle,
                  ),
                ],
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

import 'package:daily_water_tracker/features/home/coefficient_format.dart';
import 'package:daily_water_tracker/features/home/widgets/drink_type_svgs.dart';
import 'package:daily_water_tracker/features/home/widgets/edit_water_record_sheet.dart';
import 'package:daily_water_tracker/features/home/widgets/hydration_drink_row.dart';
import 'package:daily_water_tracker/features/theme/app_theme_extensions.dart';
import 'package:daily_water_tracker/features/theme/theme_colors.dart';
import 'package:daily_water_tracker/features/home/widgets/hydration_info_sheet.dart';
import 'package:daily_water_tracker/features/home/widgets/home_date_bar.dart';
import 'package:daily_water_tracker/firebase/models/water_record_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class HomeDrinksListDivider extends StatelessWidget {
  const HomeDrinksListDivider({super.key});

  static const double _height = 0.95;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      width: double.infinity,
      child: CustomPaint(
        painter: _HorizontalTaperedDividerPainter(),
      ),
    );
  }
}

class _HorizontalTaperedDividerPainter extends CustomPainter {
  _HorizontalTaperedDividerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width * 0.995;
    final left = (size.width - w) / 2;
    const t = _HorizontalRulePainter.lineThickness;
    final rect = Rect.fromLTWH(
      left,
      (size.height - t) / 2,
      w,
      t,
    );

    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(_HorizontalRulePainter.lineThickness / 2),
    );

    final base = AppPalette.drinksListFade;
    final shader = LinearGradient(
      colors: [
        base.withValues(alpha: 0),
        base.withValues(alpha: 0.10),
        base.withValues(alpha: 0.22),
        base.withValues(alpha: 0.29),
        base.withValues(alpha: 0.22),
        base.withValues(alpha: 0.10),
        base.withValues(alpha: 0),
      ],
      stops: [0.0, 0.10, 0.22, 0.5, 0.78, 0.90, 1.0],
    ).createShader(rect);

    canvas.drawRRect(rrect, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HorizontalRulePainter {
  static const double lineThickness = 0.72;
}

class HomeTodayDrinksPanel extends StatelessWidget {
  const HomeTodayDrinksPanel({
    super.key,
    required this.records,
  });

  final List<WaterRecordModel> records;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final locale = Localizations.localeOf(context).toString();
    final timeFormat = DateFormat('HH:mm', locale);

    final sorted = List<WaterRecordModel>.from(records)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: context.appColors.dateBarIcon,
      letterSpacing: -0.25,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, right: 2, bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  LocaleKeys.home_today_drinks_title.tr(),
                  style: titleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                icon: SvgPicture.asset(
                  kDrinkListInfoSvg,
                  width: 22,
                  height: 22,
                  excludeFromSemantics: true,
                ),
                onPressed: () => showHydrationInfoSheet(context),
                tooltip: LocaleKeys.home_tooltip_info.tr(),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: sorted.length,
            separatorBuilder: (_, _) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 3),
              child: HomeDrinksListDivider(),
            ),
            itemBuilder: (context, index) {
              final r = sorted[index];
              return HydrationDrinkRow(
                record: r,
                timeLabel: timeFormat.format(r.timestamp),
                coeffLabel: formatCoefficientUi(r.coefficient),
                mutedColor: colors.progressLabelMuted.withValues(alpha: 0.95),
                onTap: () => showEditWaterRecordSheet(context, record: r),
                trailing: const SizedBox(
                  height: 22,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: HomeDateBarChevronRight(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

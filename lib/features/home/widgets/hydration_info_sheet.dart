import 'package:daily_water_tracker/common/l10n/drink_type_l10n.dart';
import 'package:daily_water_tracker/features/home/coefficient_format.dart';
import 'package:daily_water_tracker/features/home/widgets/drink_type_svgs.dart';
import 'package:daily_water_tracker/features/home/widgets/water_progress_indicator.dart';
import 'package:daily_water_tracker/features/theme/app_theme_extensions.dart';
import 'package:daily_water_tracker/firebase/models/drink_type.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Future<void> showHydrationInfoSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: AppDecorations.transparent,
    barrierColor: AppDecorations.modalBarrier(),
    builder: (ctx) {
      final maxH = MediaQuery.sizeOf(ctx).height * 0.92;
      return Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(ctx).pop(),
            child: const SizedBox.expand(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxH),
              child: const HydrationInfoSheet(),
            ),
          ),
        ],
      );
    },
  );
}

class HydrationInfoSheet extends StatelessWidget {
  const HydrationInfoSheet({super.key});

  static const double _kIconSize = 30;
  static const double _kDividerIndent = 52;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final colors = context.appColors;
    final graphite = colors.progressValueText;
    final muted = colors.progressLabelMuted;
    final formulaCardBg = WaterProgressIndicator.gradientTailSoft.withValues(
      alpha: 0.12,
    );

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: Material(
        color: colors.sheetSurface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SheetDragHandle(),
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    LocaleKeys.hydration_info_title.tr(),
                    textAlign: TextAlign.center,
                    style: theme.titleLarge?.copyWith(
                      color: graphite,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.35,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    LocaleKeys.hydration_info_subtitle.tr(),
                    textAlign: TextAlign.center,
                    style: theme.bodyMedium?.copyWith(
                      color: muted,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                    decoration: BoxDecoration(
                      color: formulaCardBg,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text.rich(
                          TextSpan(
                            style: theme.titleSmall?.copyWith(
                              color: graphite,
                              height: 1.35,
                              letterSpacing: -0.2,
                            ),
                            children: [
                              TextSpan(
                                text: LocaleKeys.hydration_info_formula_volume.tr(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextSpan(
                                text: '  ×  ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: muted,
                                ),
                              ),
                              TextSpan(
                                text: LocaleKeys.hydration_info_formula_coefficient.tr(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextSpan(
                                text: '  =  ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: muted,
                                ),
                              ),
                              TextSpan(
                                text: LocaleKeys.hydration_info_formula_hydration.tr(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          LocaleKeys.hydration_info_example.tr(),
                          textAlign: TextAlign.center,
                          style: theme.bodySmall?.copyWith(
                            color: muted,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    LocaleKeys.hydration_info_defaults_title.tr(),
                    style: theme.titleSmall?.copyWith(
                      color: graphite,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._coefficientRows(graphite, muted, theme),
                  const SizedBox(height: 20),
                  Text(
                    LocaleKeys.hydration_info_body.tr(),
                    style: theme.bodyMedium?.copyWith(
                      color: muted,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _coefficientRows(
    Color graphite,
    Color muted,
    TextTheme theme,
  ) {
    const types = DrinkType.values;
    final out = <Widget>[];
    for (var i = 0; i < types.length; i++) {
      if (i > 0) {
        out.add(_InsetDivider(color: muted));
      }
      final t = types[i];
      final coeff = formatCoefficientUi(t.defaultCoefficient);
      out.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: _kIconSize,
                height: _kIconSize,
                child: SvgPicture.asset(
                  drinkTypeRowSvgAsset(t),
                  excludeFromSemantics: true,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  t.localizedLabel,
                  style: theme.titleSmall?.copyWith(
                    color: graphite,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.15,
                  ),
                ),
              ),
              Text(
                '×$coeff',
                style: theme.titleSmall?.copyWith(
                  color: graphite,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return out;
  }
}

class _SheetDragHandle extends StatelessWidget {
  const _SheetDragHandle();

  @override
  Widget build(BuildContext context) {
    const muted = WaterProgressIndicator.labelMuted;
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: muted.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _InsetDivider extends StatelessWidget {
  const _InsetDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: HydrationInfoSheet._kDividerIndent,
      ),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: color.withValues(alpha: 0.28),
      ),
    );
  }
}

import 'package:daily_water_tracker/common/l10n/drink_type_l10n.dart';
import 'package:daily_water_tracker/common/widgets/app_primary_button.dart';
import 'package:daily_water_tracker/features/home/widgets/drink_type_svgs.dart';
import 'package:daily_water_tracker/features/home/widgets/water_progress_indicator.dart';
import 'package:daily_water_tracker/features/theme/app_theme_extensions.dart';
import 'package:daily_water_tracker/features/theme/theme_colors.dart';
import 'package:daily_water_tracker/firebase/models/drink_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const double kWaterSheetCardRadius = 24;

Color waterSheetHydrationLineColor(DrinkType type) {
  switch (type) {
    case DrinkType.water:
      return WaterProgressIndicator.gradientMid;
    case DrinkType.coffee:
      return AppPalette.drinkCoffee;
    case DrinkType.greenTea:
      return AppPalette.drinkGreenTea;
    case DrinkType.milk:
      return AppPalette.drinkMilk;
  }
}

class WaterSheetHandle extends StatelessWidget {
  const WaterSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = context.appColors.progressLabelMuted;
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 8),
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

class WaterDrinkChoiceChip extends StatelessWidget {
  const WaterDrinkChoiceChip({
    super.key,
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final DrinkType type;
  final bool selected;
  final VoidCallback onTap;

  static const double _kChipRadius = 18;
  static const double _iconSize = 32;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final muted = colors.progressLabelMuted;

    final svg = SvgPicture.asset(
      drinkTypeRowSvgAsset(type),
      width: _iconSize,
      height: _iconSize,
      excludeFromSemantics: true,
    );

    final iconChild = selected
        ? ColorFiltered(
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            child: svg,
          )
        : ColorFiltered(
            colorFilter: ColorFilter.mode(
              muted.withValues(alpha: 0.65),
              BlendMode.srcIn,
            ),
            child: svg,
          );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_kChipRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 10),
          decoration: BoxDecoration(
            color: selected
                ? WaterProgressIndicator.gradientTailSoft
                : colors.chipUnselectedBg,
            borderRadius: BorderRadius.circular(_kChipRadius),
            border: Border.all(
              color: selected
                  ? Colors.white.withValues(alpha: 0.22)
                  : colors.chipUnselectedBorder,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: WaterProgressIndicator.gradientTailSoft.withValues(
                        alpha: 0.42,
                      ),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: _iconSize,
                child: Center(child: iconChild),
              ),
              const SizedBox(height: 6),
              Text(
                type.localizedLabel,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10.5,
                  height: 1.2,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  letterSpacing: -0.05,
                  color: selected ? Colors.white : muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WaterSpringStepButton extends StatefulWidget {
  const WaterSpringStepButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  State<WaterSpringStepButton> createState() => _WaterSpringStepButtonState();
}

class _WaterSpringStepButtonState extends State<WaterSpringStepButton> {
  bool _pressed = false;

  Future<void> _runTap() async {
    if (!widget.enabled) return;
    setState(() => _pressed = true);
    widget.onTap();
    await Future<void>.delayed(const Duration(milliseconds: 110));
    if (mounted) setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final graphite = colors.progressValueText;
    final muted = colors.progressLabelMuted;

    return AnimatedScale(
      scale: _pressed ? 0.9 : 1.0,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOutBack,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.enabled ? _runTap : null,
          customBorder: const CircleBorder(),
          child: Ink(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.chipUnselectedBg,
              border: Border.all(
                color: muted.withValues(alpha: 0.22),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              widget.icon,
              size: 28,
              color: widget.enabled
                  ? graphite
                  : graphite.withValues(alpha: 0.35),
            ),
          ),
        ),
      ),
    );
  }
}

class WaterCapsuleButton extends StatelessWidget {
  const WaterCapsuleButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.enabled,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final graphite = colors.progressValueText;
    final muted = colors.progressLabelMuted;

    final borderColor = selected
        ? WaterProgressIndicator.gradientTailSoft.withValues(alpha: 0.55)
        : muted.withValues(alpha: enabled ? 0.32 : 0.16);

    final bg = selected
        ? WaterProgressIndicator.gradientTailSoft.withValues(alpha: 0.12)
        : colors.chipUnselectedBg;

    final textColor = selected
        ? WaterProgressIndicator.gradientHeadDeep
        : (enabled ? graphite : graphite.withValues(alpha: 0.38));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

class WaterGradientCtaButton extends StatelessWidget {
  const WaterGradientCtaButton({
    super.key,
    required this.enabled,
    required this.busy,
    required this.onTap,
    required this.label,
  });

  final bool enabled;
  final bool busy;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppGradientButton(
      label: label,
      enabled: enabled,
      busy: busy,
      onTap: onTap,
    );
  }
}

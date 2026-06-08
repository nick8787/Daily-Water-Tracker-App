import 'package:daily_water_tracker/features/theme/app_theme_extensions.dart';
import 'package:daily_water_tracker/features/vibration/vibration_feedback.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HomeDateBar extends StatelessWidget {
  const HomeDateBar({
    super.key,
    required this.weekdayLine,
    required this.dateLine,
    required this.onOpenCalendar,
    required this.onPreviousDay,
    required this.onNextDay,
    required this.canGoNext,
  });

  final String weekdayLine;
  final String dateLine;
  final VoidCallback onOpenCalendar;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;
  final bool canGoNext;

  static const double preferredHeight = 66;

  static const BorderRadius _barRadius = BorderRadius.all(Radius.circular(22));

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.appColors;

    return Semantics(
      container: true,
      label: LocaleKeys.home_semantics_selected_day.tr(namedArgs: {'weekday': weekdayLine, 'date': dateLine}),
      child: Container(
        decoration: BoxDecoration(
          color: colors.dateBarSurface,
          borderRadius: _barRadius,
          boxShadow: colors.cardShadow,
        ),
        child: Material(
          type: MaterialType.transparency,
          clipBehavior: Clip.antiAlias,
          borderRadius: _barRadius,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 7, 4, 7),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    button: true,
                    label: LocaleKeys.home_semantics_choose_date.tr(),
                    child: InkWell(
                      onTap: () => VibrationFeedback.run(context, onOpenCalendar),
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 3, 10, 3),
                        child: Row(
                          children: [
                            _SolidTriangle(
                              kind: _TriangleKind.down,
                              size: const Size(10, 6),
                              color: colors.dateBarIcon,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    weekdayLine,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.labelMedium?.copyWith(
                                      fontSize: 13,
                                      height: 1.1,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.15,
                                      color: colors.dateBarTitle,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    dateLine,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.titleSmall?.copyWith(
                                      fontSize: 15.5,
                                      height: 1.1,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                      color: colors.dateBarTitle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                _NavArrow(
                  pointLeft: true,
                  tooltip: LocaleKeys.home_tooltip_previous_day.tr(),
                  onPressed: () => VibrationFeedback.run(context, onPreviousDay),
                  enabledColor: colors.dateBarIcon,
                  disabledColor: colors.dateBarIconDisabled,
                ),
                _TaperedVerticalDivider(accent: colors.dateBarIcon),
                _NavArrow(
                  pointLeft: false,
                  tooltip: LocaleKeys.home_tooltip_next_day.tr(),
                  onPressed: canGoNext
                      ? () => VibrationFeedback.run(context, onNextDay)
                      : null,
                  enabledColor: colors.dateBarIcon,
                  disabledColor: colors.dateBarIconDisabled,
                ),
                const SizedBox(width: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  const _NavArrow({
    required this.pointLeft,
    required this.tooltip,
    required this.onPressed,
    required this.enabledColor,
    required this.disabledColor,
  });

  final bool pointLeft;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color enabledColor;
  final Color disabledColor;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final color = enabled ? enabledColor : disabledColor;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: _SolidTriangle(
                kind: pointLeft ? _TriangleKind.left : _TriangleKind.right,
                size: pointLeft ? const Size(7, 11) : const Size(7, 11),
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _TriangleKind { down, left, right }

class _SolidTriangle extends StatelessWidget {
  const _SolidTriangle({
    required this.kind,
    required this.size,
    required this.color,
  });

  final _TriangleKind kind;
  final Size size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: _SolidTrianglePainter(kind: kind, color: color),
    );
  }
}

class _SolidTrianglePainter extends CustomPainter {
  _SolidTrianglePainter({required this.kind, required this.color});

  final _TriangleKind kind;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    switch (kind) {
      case _TriangleKind.down:
        path
          ..moveTo(0, 0)
          ..lineTo(size.width * 0.5, size.height)
          ..lineTo(size.width, 0)
          ..close();
      case _TriangleKind.left:
        path
          ..moveTo(size.width, 0)
          ..lineTo(0, size.height * 0.5)
          ..lineTo(size.width, size.height)
          ..close();
      case _TriangleKind.right:
        path
          ..moveTo(0, 0)
          ..lineTo(size.width, size.height * 0.5)
          ..lineTo(0, size.height)
          ..close();
    }
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SolidTrianglePainter oldDelegate) {
    return oldDelegate.kind != kind || oldDelegate.color != color;
  }
}

class _TaperedVerticalDivider extends StatelessWidget {
  const _TaperedVerticalDivider({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      height: 58,
      child: CustomPaint(
        painter: _TaperedVerticalDividerPainter(accent: accent),
      ),
    );
  }
}

class _TaperedVerticalDividerPainter extends CustomPainter {
  _TaperedVerticalDividerPainter({required this.accent});

  final Color accent;

  static const double _lineWidth = 1.1;

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height * 0.99;
    final top = (size.height - h) / 2;
    final rect = Rect.fromLTWH(
      (size.width - _lineWidth) / 2,
      top,
      _lineWidth,
      h,
    );

    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(_lineWidth / 2),
    );

    final shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        accent.withValues(alpha: 0),
        accent.withValues(alpha: 0.4),
        accent.withValues(alpha: 0.91),
        accent.withValues(alpha: 0.91),
        accent.withValues(alpha: 0.4),
        accent.withValues(alpha: 0),
      ],
      stops: const [0.0, 0.12, 0.22, 0.78, 0.88, 1.0],
    ).createShader(rect);

    canvas.drawRRect(rrect, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _TaperedVerticalDividerPainter oldDelegate) {
    return oldDelegate.accent != accent;
  }
}

class HomeDateBarChevronRight extends StatelessWidget {
  const HomeDateBarChevronRight({super.key});

  @override
  Widget build(BuildContext context) {
    return _SolidTriangle(
      kind: _TriangleKind.right,
      size: const Size(7, 11),
      color: context.appColors.dateBarIcon,
    );
  }
}

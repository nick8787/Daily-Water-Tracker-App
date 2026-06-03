import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

import 'package:daily_water_tracker/features/theme/app_theme_extensions.dart';
import 'package:daily_water_tracker/features/theme/text_styles.dart';
import 'package:daily_water_tracker/features/theme/theme_colors.dart';
import 'package:daily_water_tracker/firebase/services/remote_config_service.dart';
import 'package:percent_indicator/percent_indicator.dart';

class WaterProgressIndicator extends StatefulWidget {
  const WaterProgressIndicator({
    super.key,
    required this.currentAmount,
    required this.goalAmount,
    required this.type,
    this.trackStrokeWidth = 58,
    this.progressStrokeWidth = 35,
    this.animationDuration = const Duration(milliseconds: 1150),
  });

  final int currentAmount;
  final int goalAmount;
  final ProgressIndicatorType type;

  final double trackStrokeWidth;
  final double progressStrokeWidth;
  final Duration animationDuration;

  static const Color gradientTailSoft = AppPalette.progressGradientTail;
  static const Color gradientMid = AppPalette.progressGradientMid;
  static const Color gradientHeadDeep = AppPalette.progressGradientHead;

  /// Light-theme fallback for `const` call sites — prefer [AppColors] in widgets.
  @Deprecated('Use context.appColors.progressLabelMuted')
  static const Color labelMuted = AppPalette.progressLabelMutedLight;

  @Deprecated('Use context.appColors.progressValueText')
  static const Color valueGraphite = AppPalette.progressValueLight;

  @override
  State<WaterProgressIndicator> createState() => _WaterProgressIndicatorState();
}

class _WaterProgressIndicatorState extends State<WaterProgressIndicator> {
  double _progressRatio() {
    if (widget.goalAmount <= 0) return 0;
    return (widget.currentAmount / widget.goalAmount).clamp(0.0, 2.0);
  }

  Widget _centerContent(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            LocaleKeys.home_progress_done.tr(),
            textAlign: TextAlign.center,
            style: AppTypography.progressRingCaption(colors.progressLabelMuted),
          ),
          const SizedBox(height: 6),
          Text(
            '${widget.currentAmount}',
            textAlign: TextAlign.center,
            style: AppTypography.progressRingValue(colors.progressValueText),
          ),
          const SizedBox(height: 4),
          Text(
            LocaleKeys.home_progress_of_goal.tr(namedArgs: {'goal': '${widget.goalAmount}'}),
            textAlign: TextAlign.center,
            style: AppTypography.progressRingSubtitle(colors.progressLabelMuted),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final ratio = _progressRatio();
    final percent = ratio.clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);

        switch (widget.type) {
          case ProgressIndicatorType.circular:
            return _LegacyCircularWaterRing(
              side: side,
              currentAmount: widget.currentAmount,
              goalAmount: widget.goalAmount,
              trackStrokeWidth: widget.trackStrokeWidth,
              progressStrokeWidth: widget.progressStrokeWidth,
              animationDuration: widget.animationDuration,
              center: _centerContent(context),
            );
          case ProgressIndicatorType.linear:
            const horizontalPadding = 6.0;
            final availableWidth = math.max(
              0.0,
              constraints.maxWidth - horizontalPadding * 2,
            );
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: horizontalPadding,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _centerContent(context),
                  const SizedBox(height: 18),
                  LinearPercentIndicator(
                    width: availableWidth,
                    lineHeight: 18,
                    percent: percent,
                    animation: true,
                    animationDuration: widget.animationDuration.inMilliseconds,
                    animateFromLastPercent: true,
                    backgroundColor: colors.progressTrack,
                    linearGradient: const LinearGradient(
                      colors: [
                        WaterProgressIndicator.gradientTailSoft,
                        WaterProgressIndicator.gradientMid,
                        WaterProgressIndicator.gradientHeadDeep,
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                    barRadius: const Radius.circular(12),
                  ),
                ],
              ),
            );
        }
      },
    );
  }
}

class _LegacyCircularWaterRing extends StatefulWidget {
  const _LegacyCircularWaterRing({
    Key? key,
    required this.side,
    required this.currentAmount,
    required this.goalAmount,
    required this.trackStrokeWidth,
    required this.progressStrokeWidth,
    required this.animationDuration,
    required this.center,
  }) : super(key: key);

  final double side;
  final int currentAmount;
  final int goalAmount;
  final double trackStrokeWidth;
  final double progressStrokeWidth;
  final Duration animationDuration;
  final Widget center;

  @override
  State<_LegacyCircularWaterRing> createState() =>
      _LegacyCircularWaterRingState();
}

class _LegacyCircularWaterRingState extends State<_LegacyCircularWaterRing> {
  double _tweenBegin = 0;
  double _tweenEnd = 0;
  int _animationGeneration = 0;

  double _progressRatio() {
    if (widget.goalAmount <= 0) return 0;
    return (widget.currentAmount / widget.goalAmount).clamp(0.0, 2.0);
  }

  @override
  void initState() {
    super.initState();
    _tweenEnd = _progressRatio();
    _tweenBegin = 0;
  }

  @override
  void didUpdateWidget(covariant _LegacyCircularWaterRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentAmount == oldWidget.currentAmount &&
        widget.goalAmount == oldWidget.goalAmount &&
        widget.trackStrokeWidth == oldWidget.trackStrokeWidth &&
        widget.progressStrokeWidth == oldWidget.progressStrokeWidth) {
      return;
    }
    _tweenBegin = _tweenEnd;
    _tweenEnd = _progressRatio();
    _animationGeneration++;
  }

  @override
  Widget build(BuildContext context) {
    final maxStroke = math.max(
      widget.trackStrokeWidth,
      widget.progressStrokeWidth,
    );

    return SizedBox(
      width: widget.side,
      height: widget.side,
      child: TweenAnimationBuilder<double>(
        key: ValueKey<int>(_animationGeneration),
        duration: widget.animationDuration,
        curve: Curves.easeInOutCubic,
        tween: Tween<double>(begin: _tweenBegin, end: _tweenEnd),
        builder: (context, animatedProgress, child) {
          final trackColor = context.appColors.progressTrack;
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size(widget.side, widget.side),
                painter: _GrooveWaterRingPainter(
                  progress: animatedProgress,
                  trackStrokeWidth: widget.trackStrokeWidth,
                  progressStrokeWidth: widget.progressStrokeWidth,
                  layoutMargin: maxStroke / 2,
                  trackColor: trackColor,
                ),
              ),
              child!,
            ],
          );
        },
        child: widget.center,
      ),
    );
  }
}

class _GrooveWaterRingPainter extends CustomPainter {
  _GrooveWaterRingPainter({
    required this.progress,
    required this.trackStrokeWidth,
    required this.progressStrokeWidth,
    required this.layoutMargin,
    required this.trackColor,
  });

  final double progress;
  final double trackStrokeWidth;
  final double progressStrokeWidth;
  final double layoutMargin;
  final Color trackColor;

  static const double _startAngle = -math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - layoutMargin;
    if (radius <= 0) return;

    final rect = Rect.fromCircle(center: center, radius: radius);

    _paintTrack(canvas, rect);
    _paintProgress(canvas, center, rect, radius);
  }

  void _paintTrack(Canvas canvas, Rect rect) {
    final shadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(5.0, trackStrokeWidth * 0.14)
      ..color = AppPalette.progressRingTrackShadow
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawArc(rect, 0.03, 2 * math.pi - 0.06, false, shadowPaint);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackStrokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, 2 * math.pi, false, trackPaint);
  }

  void _paintProgress(Canvas canvas, Offset center, Rect rect, double radius) {
    if (progress <= 0) return;

    final double lap1Progress = progress.clamp(0.0, 1.0);

    const double startCutAngle = 0.018;

    final double visualLap1Progress = math.pow(lap1Progress, 0.71).toDouble();

    final double sweepAngle1 = progress >= 1.0
        ? 2 * math.pi - startCutAngle
        : 2 * math.pi * visualLap1Progress;

    final shaderRect = Rect.fromCircle(center: center, radius: radius * 1.25);
    final gradientShader = const SweepGradient(
      colors: [
        WaterProgressIndicator.gradientTailSoft,
        WaterProgressIndicator.gradientMid,
        WaterProgressIndicator.gradientHeadDeep,
      ],
      stops: [0.0, 0.5, 1.0],
      transform: GradientRotation(_startAngle),
    ).createShader(shaderRect);

    final arcPaint1 = Paint()
      ..shader = gradientShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = progressStrokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      rect,
      progress >= 1.0 ? _startAngle + startCutAngle : _startAngle,
      sweepAngle1,
      false,
      arcPaint1,
    );

    if (progress < 1.0) {
      final startOffset = Offset(
        center.dx + radius * math.cos(_startAngle),
        center.dy + radius * math.sin(_startAngle),
      );

      canvas.drawCircle(
        startOffset,
        progressStrokeWidth / 2,
        Paint()..color = WaterProgressIndicator.gradientTailSoft,
      );

      Color endColor;
      if (visualLap1Progress <= 0.5) {
        endColor = Color.lerp(
          WaterProgressIndicator.gradientTailSoft,
          WaterProgressIndicator.gradientMid,
          visualLap1Progress * 2,
        )!;
      } else {
        endColor = Color.lerp(
          WaterProgressIndicator.gradientMid,
          WaterProgressIndicator.gradientHeadDeep,
          (visualLap1Progress - 0.5) * 2,
        )!;
      }

      final endAngle1 = _startAngle + sweepAngle1;
      final endOffset1 = Offset(
        center.dx + radius * math.cos(endAngle1),
        center.dy + radius * math.sin(endAngle1),
      );

      canvas.drawCircle(
        endOffset1,
        progressStrokeWidth / 2,
        Paint()..color = endColor,
      );
    }

    if (progress >= 1.0) {
      final double lap2Progress = (progress - 1.0).clamp(0.0, 1.0);
      final double sweepAngle2 = 2 * math.pi * lap2Progress;

      final safeSweep = sweepAngle2 == 0.0 ? 0.001 : sweepAngle2;

      final arcPaint2 = Paint()
        ..color = WaterProgressIndicator.gradientHeadDeep
        ..style = PaintingStyle.stroke
        ..strokeWidth = progressStrokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, _startAngle, safeSweep, false, arcPaint2);
    }
  }

  @override
  bool shouldRepaint(covariant _GrooveWaterRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackStrokeWidth != trackStrokeWidth ||
        oldDelegate.progressStrokeWidth != progressStrokeWidth ||
        oldDelegate.layoutMargin != layoutMargin ||
        oldDelegate.trackColor != trackColor;
  }
}

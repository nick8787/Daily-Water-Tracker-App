import 'package:flutter/material.dart';
import 'package:daily_water_tracker/common/assets.dart';
import 'package:daily_water_tracker/features/theme/app_theme_extensions.dart';
import 'package:daily_water_tracker/features/theme/theme_colors.dart';

class HomeWaterCardEmpty extends StatelessWidget {
  const HomeWaterCardEmpty({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final mutedBlueText = context.appColors.homeEmptyMutedText;
    return LayoutBuilder(
      builder: (context, c) {
        final h = c.maxHeight;

        final glassW = (h * 0.50).clamp(185.0, 235.0);
        final glassTop = (h * 0.26).clamp(60.0, 100.0);
        final textTop = (h * 0.735).clamp(270.0, h - 84.0);

        return Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: glassTop,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: glassW,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          left: -glassW * 0.28,
                          right: -glassW * 0.28,
                          top: 0,
                          bottom: 0,
                          child: const ClipRect(
                            child: IgnorePointer(
                              child: CustomPaint(
                                painter: _GlassGlowPainter(),
                              ),
                            ),
                          ),
                        ),
                        Image.asset(
                          glassOfWater,
                          filterQuality: FilterQuality.high,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: textTop,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize:
                      (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) +
                      2,
                  color: mutedBlueText,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GlassGlowPainter extends CustomPainter {
  const _GlassGlowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(0, 0, size.width, size.height);

    final bottom = r.bottom;
    final sunCenter = Offset(r.left + r.width * 0.5, bottom);
    final sunRadius = r.width * 0.78;

    final sunPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30)
      ..shader = RadialGradient(
        colors: [
          AppPalette.homeEmptyCardMist.withValues(alpha: 0.50),
          AppPalette.homeEmptyCardMist.withValues(alpha: 0.24),
          AppPalette.homeEmptyCardMist.withValues(alpha: 0.06),
          AppPalette.homeEmptyCardMist.withValues(alpha: 0.00),
        ],
        stops: const [0.0, 0.30, 0.52, 1.0],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: sunRadius));

    final ovalRect = Rect.fromCenter(
      center: Offset(sunCenter.dx, bottom - r.height * 0.06),
      width: r.width * 0.92,
      height: r.height * 0.95,
    );
    canvas.drawOval(ovalRect, sunPaint);

    final hotspotPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
      ..shader =
          RadialGradient(
            colors: [
              AppPalette.homeEmptyCardMist.withValues(alpha: 0.62),
              AppPalette.homeEmptyCardMist.withValues(alpha: 0.22),
              AppPalette.homeEmptyCardMist.withValues(alpha: 0.00),
            ],
            stops: const [0.0, 0.55, 1.0],
          ).createShader(
            Rect.fromCircle(
              center: Offset(r.left + r.width * 0.5, bottom - r.height * 0.02),
              radius: r.width * 0.24,
            ),
          );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(r.left + r.width * 0.5, bottom - r.height * 0.02),
        width: r.width * 0.46,
        height: r.height * 0.20,
      ),
      hotspotPaint,
    );

    final lineRect = Rect.fromCenter(
      center: Offset(r.left + r.width / 2, bottom - 1),
      width: r.width * 0.62,
      height: 2,
    );
    final linePaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
      ..shader = LinearGradient(
        colors: [
          AppPalette.homeEmptyCardMist.withValues(alpha: 0),
          AppPalette.homeEmptyCardMist.withValues(alpha: 0.5),
          AppPalette.homeEmptyCardMist.withValues(alpha: 0.5),
          AppPalette.homeEmptyCardMist.withValues(alpha: 0),
        ],
      ).createShader(lineRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(lineRect, const Radius.circular(999)),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

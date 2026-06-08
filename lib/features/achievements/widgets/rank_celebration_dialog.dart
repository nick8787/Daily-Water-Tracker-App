import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:confetti/confetti.dart';
import 'package:daily_water_tracker/common/widgets/app_snackbar.dart';
import 'package:daily_water_tracker/features/achievements/cubit/achievements_cubit.dart';
import 'package:daily_water_tracker/features/achievements/data/achievements_registry.dart';
import 'package:daily_water_tracker/features/achievements/models/achievement_definition.dart';
import 'package:daily_water_tracker/features/achievements/models/badge_model.dart';
import 'package:daily_water_tracker/features/deep_links/services/progress_share_service.dart';
import 'package:daily_water_tracker/features/theme/decorations.dart';
import 'package:daily_water_tracker/features/theme/shadow.dart';
import 'package:daily_water_tracker/features/theme/theme_colors.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Full-screen rank ascension ceremony
abstract final class RankCelebrationDialog {

  static Future<AchievementDefinition?> show(
    BuildContext context, {
    required BadgeModel rank,
    required int todayMl,
  }) {
    return showGeneralDialog<AchievementDefinition?>(
      context: context,
      barrierLabel: LocaleKeys.achievements_celebration_barrier_label.tr(),
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return _RankCelebrationOverlay(rank: rank, todayMl: todayMl);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: child,
        );
      },
    );
  }
}

class _RankCelebrationOverlay extends StatefulWidget {
  const _RankCelebrationOverlay({
    required this.rank,
    required this.todayMl,
  });

  final BadgeModel rank;
  final int todayMl;

  @override
  State<_RankCelebrationOverlay> createState() =>
      _RankCelebrationOverlayState();
}

class _RankCelebrationOverlayState extends State<_RankCelebrationOverlay>
    with TickerProviderStateMixin {
  static const _heroSize = 156.0;
  static const _backdropBlur = 7.0;

  late final ConfettiController _confettiController;
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _heroFade;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 4),
    );
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.42),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutBack,
      ),
    );
    _heroFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0, 0.55, curve: Curves.easeOut),
    );

    _entranceController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _confettiController.play();
      unawaited(_playSuccessHaptics());
    });
  }

  Future<void> _playSuccessHaptics() async {
    HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    HapticFeedback.lightImpact();
  }

  void _onPrimaryAction() {
    final nextRank = AchievementsCubit.getNextRank(widget.rank.id);
    Navigator.of(context).pop(nextRank);
  }

  Future<void> _onShareTap(BuildContext shareContext) async {
    if (_isSharing) return;

    setState(() => _isSharing = true);
    try {
      final locale = Localizations.localeOf(shareContext).toString();
      await ProgressShareService.shareRankCelebration(
        context: shareContext,
        rank: widget.rank,
        ml: widget.todayMl,
        locale: locale,
      );
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        LocaleKeys.account_snackbar_share_failed.tr(),
      );
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  int get _primaryParticleCount =>
      _confettiParticlesForTier(widget.rank.tierOrder);

  int get _secondaryParticleCount => (_primaryParticleCount * 0.52).round();

  static int _confettiParticlesForTier(int tierOrder) {
    const minParticles = 30;
    const maxParticles = 100;
    final maxTier = AchievementsRegistry.all.length - 1;
    if (maxTier <= 0) return maxParticles;
    return minParticles +
        ((maxParticles - minParticles) * tierOrder / maxTier).round();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.sizeOf(context);
    final cardWidth = math.min(size.width - 40, 360.0);

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: _backdropBlur,
                sigmaY: _backdropBlur,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _atmosphereTop.withValues(alpha: 0.58),
                    _atmosphereBottom.withValues(alpha: 0.64),
                  ],
                ),
              ),
            ),
          ),
          ..._confettiLayers(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  FadeTransition(
                    opacity: _heroFade,
                    child: _PulsingRankHero(
                      rank: widget.rank,
                      pulseController: _pulseController,
                      size: _heroSize,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SlideTransition(
                    position: _cardSlide,
                    child: FadeTransition(
                      opacity: _entranceController,
                      child: _SuccessCard(
                        rank: widget.rank,
                        width: cardWidth,
                        textTheme: textTheme,
                        scheme: scheme,
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                  _PrimaryCelebrationButton(
                    label: LocaleKeys.achievements_celebration_primary_action.tr(),
                    onPressed: _onPrimaryAction,
                  ),
                  const SizedBox(height: 8),
                  Builder(
                    builder: (shareContext) {
                      return TextButton.icon(
                        onPressed: _isSharing
                            ? null
                            : () => _onShareTap(shareContext),
                        icon: _isSharing
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppPalette.white.withValues(alpha: 0.88),
                                ),
                              )
                            : Icon(
                                Icons.share_outlined,
                                size: 20,
                                color: AppPalette.white.withValues(alpha: 0.88),
                              ),
                        label: Text(
                          LocaleKeys.achievements_celebration_share.tr(),
                          style: textTheme.labelLarge?.copyWith(
                            color: AppPalette.white.withValues(
                              alpha: _isSharing ? 0.55 : 0.88,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _confettiLayers() {
    const confettiColors = [
      AppPalette.brandBlue,
      AppPalette.progressGradientTail,
      AppPalette.progressGradientMid,
      AppPalette.navFabGradientTop,
      AppPalette.white,
    ];

    return [
      Align(
        child: ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          maxBlastForce: 42,
          minBlastForce: 18,
          emissionFrequency: 0.035,
          numberOfParticles: _primaryParticleCount,
          gravity: 0.14,
          particleDrag: 0.03,
          colors: confettiColors,
        ),
      ),
      Align(
        alignment: const Alignment(0, -0.15),
        child: ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          maxBlastForce: 36,
          minBlastForce: 14,
          emissionFrequency: 0.05,
          numberOfParticles: _secondaryParticleCount,
          gravity: 0.1,
          particleDrag: 0.02,
          colors: confettiColors,
        ),
      ),
    ];
  }

  static const _atmosphereTop = Color(0xFF0F2347);
  static const _atmosphereBottom = Color(0xFF091528);
}

class _PulsingRankHero extends StatelessWidget {
  const _PulsingRankHero({
    required this.rank,
    required this.pulseController,
    required this.size,
  });

  final BadgeModel rank;
  final AnimationController pulseController;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final scale = Tween<double>(begin: 1, end: 1.14).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );

    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        return Transform.scale(scale: scale.value, child: child);
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: scheme.surface,
          border: Border.all(
            color: scheme.primary.withValues(alpha: 0.95),
            width: 4.5,
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.55),
              blurRadius: 28,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: AppPalette.progressGradientTail.withValues(alpha: 0.45),
              blurRadius: 52,
              spreadRadius: 6,
            ),
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.22),
              blurRadius: 88,
              spreadRadius: 14,
            ),
          ],
        ),
        child: Icon(
          rank.placeholderIcon,
          size: size * 0.44,
          color: scheme.primary,
        ),
      ),
    );
  }
}

class _SuccessCard extends StatelessWidget {
  const _SuccessCard({
    required this.rank,
    required this.width,
    required this.textTheme,
    required this.scheme,
  });

  final BadgeModel rank;
  final double width;
  final TextTheme textTheme;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 34),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.14),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.08),
            blurRadius: 40,
            spreadRadius: -4,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            LocaleKeys.achievements_celebration_congrats.tr(),
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            LocaleKeys.achievements_celebration_new_status.tr(),
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.55),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          _GradientRankTitle(
            text: rank.nameKey.tr(),
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }
}

/// Gradient rank title without [ShaderMask] clipping ascenders/descenders.
class _GradientRankTitle extends StatelessWidget {
  const _GradientRankTitle({
    required this.text,
    required this.textTheme,
  });

  final String text;
  final TextTheme textTheme;

  static const _gradient = LinearGradient(
    colors: AppPalette.progressGradientColors,
  );

  @override
  Widget build(BuildContext context) {
    final style = textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.bold,
      height: 1.22,
    );
    if (style == null) {
      return Text(text, textAlign: TextAlign.center);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final direction = Directionality.of(context);
        final painter = TextPainter(
          text: TextSpan(text: text, style: style),
          textAlign: TextAlign.center,
          textDirection: direction,
          maxLines: 2,
        )..layout(maxWidth: constraints.maxWidth);

        // Extra vertical room so bold caps and descenders are never clipped.
        const verticalPad = 8.0;
        final boxWidth = constraints.maxWidth;
        final boxHeight = painter.height + verticalPad * 2;

        return SizedBox(
          width: boxWidth,
          height: boxHeight,
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: style.copyWith(
                foreground: Paint()
                  ..shader = _gradient.createShader(
                    Rect.fromLTWH(0, 0, boxWidth, boxHeight),
                  ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PrimaryCelebrationButton extends StatelessWidget {
  const _PrimaryCelebrationButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: AppDecorations.primaryButton,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppShadows.primaryButton(AppPalette.progressGradientHead),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppPalette.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

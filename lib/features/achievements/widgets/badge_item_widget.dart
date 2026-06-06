import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:daily_water_tracker/features/achievements/models/badge_model.dart';
import 'package:daily_water_tracker/features/theme/app_theme_extensions.dart';
import 'package:daily_water_tracker/features/theme/theme_info.dart';

class BadgeItemWidget extends StatelessWidget {
  const BadgeItemWidget({super.key, required this.badge});

  final BadgeModel badge;

  static const double _lockedIconSize = 52;
  static const double _unlockedIconSize = 60;
  static const double _progressHeight = 7;
  static const Duration _progressAnimDuration = Duration(milliseconds: 900);

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: _cardDecoration(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIcon(context),
          const SizedBox(height: 12),
          _buildTitle(context),
          const SizedBox(height: 6),
          if (badge.isUnlocked)
            _buildUnlockDate(context)
          else ...[
            _buildDescription(context),
            const SizedBox(height: 10),
            _buildProgress(context),
          ],
        ],
      ),
    );

    if (badge.isUnlocked) return content;

    return Opacity(opacity: 0.68, child: content);
  }

  BoxDecoration _cardDecoration(BuildContext context) {
    if (!badge.isUnlocked) {
      return appCardDecoration(context, radius: 24);
    }

    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glowAlpha = isDark ? 0.18 : 0.16;

    return BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colors.cardSurface,
          Color.lerp(
            colors.cardSurface,
            scheme.primary,
            isDark ? 0.14 : 0.1,
          )!,
        ],
      ),
      boxShadow: [
        ...colors.cardShadow,
        BoxShadow(
          color: scheme.primary.withValues(alpha: glowAlpha),
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  Widget _buildIcon(BuildContext context) {
    final locked = !badge.isUnlocked;
    final size = locked ? _lockedIconSize : _unlockedIconSize;
    final muted = Theme.of(context).colorScheme.onSurface.withValues(
      alpha: locked ? 0.38 : 0.55,
    );

    return SvgPicture.asset(
      badge.iconPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      colorFilter: locked
          ? ColorFilter.mode(muted, BlendMode.srcIn)
          : null,
      errorBuilder: (_, _, _) => _buildIconFallback(
        context,
        locked: locked,
        size: size,
      ),
    );
  }

  Widget _buildIconFallback(
    BuildContext context, {
    required bool locked,
    required double size,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final bg = locked
        ? scheme.surfaceContainerHighest.withValues(alpha: 0.65)
        : brandBlue.withValues(alpha: 0.16);
    final fg = locked ? scheme.onSurface.withValues(alpha: 0.35) : brandBlue;
    final iconSize = locked ? 28.0 : 32.0;

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: bg,
      child: Icon(Icons.military_tech_rounded, size: iconSize, color: fg),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      badge.nameKey.tr(),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
        height: 1.15,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildUnlockDate(BuildContext context) {
    final date = badge.unlockDate;
    if (date == null) return const SizedBox.shrink();

    final formatted = DateFormat(
      'dd MMM yyyy',
      context.locale.toString(),
    ).format(date);

    return Text(
      formatted,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
        height: 1.25,
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      badge.descriptionKey.tr(),
      textAlign: TextAlign.center,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
        height: 1.35,
      ),
    );
  }

  Widget _buildProgress(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final target = badge.progressFraction;
    final currentLabel = _formatProgressValue(badge.currentProgress);
    final maxLabel = _formatProgressValue(badge.maxProgress);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '$currentLabel / $maxLabel',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface.withValues(alpha: 0.5),
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: target),
          duration: _progressAnimDuration,
          curve: Curves.easeOutCubic,
          builder: (context, value, _) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: _progressHeight,
                value: value,
                backgroundColor: scheme.surfaceContainerHighest.withValues(
                  alpha: 0.85,
                ),
                color: scheme.primary,
              ),
            );
          },
        ),
      ],
    );
  }

  static String _formatProgressValue(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }
}

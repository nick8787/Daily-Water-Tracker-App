import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:daily_water_tracker/common/widgets/app_bottom_sheet.dart';
import 'package:daily_water_tracker/common/widgets/app_primary_button.dart';
import 'package:daily_water_tracker/features/theme/app_theme_extensions.dart';
import 'package:daily_water_tracker/features/theme/text_styles.dart';
import 'package:daily_water_tracker/features/theme/theme_colors.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

/// Bottom sheet shown when the app opens a shared hydration progress link
abstract final class ShareProgressSheet {
  ShareProgressSheet._();

  static Future<void> show(
    BuildContext context, {
    required int ml,
  }) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: AppDecorations.transparent,
      barrierColor: AppDecorations.modalBarrier(),
      builder: (sheetContext) =>
          AppBottomSheet(child: _ShareProgressSheetBody(ml: ml)),
    );
  }
}

class _ShareProgressSheetBody extends StatelessWidget {
  const _ShareProgressSheetBody({required this.ml});

  final int ml;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final locale = Localizations.localeOf(context).toString();
    final formattedMl = NumberFormat.decimalPattern(locale).format(ml);
    final muted = colors.progressLabelMuted;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ShareHeroIcon(),
          const SizedBox(height: 18),
          Text(
            LocaleKeys.deep_link_shared_title.tr(),
            textAlign: TextAlign.center,
            style: AppTypography.progressRingCaption(muted, textTheme).copyWith(
              fontSize: 13,
              letterSpacing: 0.08,
            ),
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: formattedMl,
                  style: AppTypography.sheetVolumeDisplay(
                    colors.progressValueText,
                    textTheme,
                  ),
                ),
                TextSpan(
                  text: ' ml',
                  style: AppTypography.progressRingCaption(
                    AppPalette.brandBlue,
                    textTheme,
                  ).copyWith(fontSize: 22, height: 1.1),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            LocaleKeys.deep_link_shared_drank_today.tr(),
            textAlign: TextAlign.center,
            style: AppTypography.progressRingSubtitle(muted, textTheme),
          ),
          const SizedBox(height: 18),
          Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 18),
          Text(
            LocaleKeys.deep_link_shared_message.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.dateBarTitle,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          AppGradientButton(
            label: LocaleKeys.deep_link_shared_primary_action.tr(),
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: muted,
            ),
            child: Text(
              LocaleKeys.deep_link_shared_secondary_action.tr(),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: muted,
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _ShareHeroIcon extends StatelessWidget {
  const _ShareHeroIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppDecorations.navFab,
        boxShadow: [
          BoxShadow(
            color: AppPalette.brandBlue.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(
        Icons.water_drop_rounded,
        color: AppPalette.white,
        size: 36,
      ),
    );
  }
}

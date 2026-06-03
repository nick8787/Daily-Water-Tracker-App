import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

import 'package:daily_water_tracker/features/theme/app_theme_extensions.dart';
import 'package:daily_water_tracker/features/theme/theme_info.dart';

class HistoryEmptyState extends StatelessWidget {
  const HistoryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body =
        theme.textTheme.bodyLarge?.copyWith(
          height: 1.45,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.52),
        ) ??
        TextStyle(
          height: 1.45,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.52),
        );

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: context.appColors.cardSurface,
                shape: BoxShape.circle,
                boxShadow: context.appColors.cardShadow,
              ),
              child: Icon(
                Icons.local_drink_outlined,
                size: 44,
                color: brandBlue.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              LocaleKeys.history_empty_title.tr(),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.35,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              LocaleKeys.history_empty_body.tr(),
              textAlign: TextAlign.center,
              style: body,
            ),
          ],
        ),
      ),
    );
  }
}

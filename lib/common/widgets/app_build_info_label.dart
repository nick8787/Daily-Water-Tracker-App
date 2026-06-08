import 'package:daily_water_tracker/common/services/app_build_info.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// Installed app version pinned to the bottom of a screen, e.g. `Version 0.0.15 (15)`.
class AppBuildInfoLabel extends StatelessWidget {
  const AppBuildInfoLabel({super.key});

  static const EdgeInsets _padding = EdgeInsets.fromLTRB(20, 12, 20, 4);

  @override
  Widget build(BuildContext context) {
    final buildInfo = GetIt.I.get<AppBuildInfo>();
    final colorScheme = Theme.of(context).colorScheme;
    final labelColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.55);
    final valueColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.82);

    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: labelColor,
      fontSize: 11,
      letterSpacing: 0.2,
      fontWeight: FontWeight.w500,
    );
    final valueStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: valueColor,
      fontSize: 11,
      letterSpacing: -0.05,
      fontWeight: FontWeight.w600,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Padding(
      padding: _padding,
      child: Align(
        alignment: Alignment.centerRight,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: LocaleKeys.account_app_version_label.tr(),
                style: labelStyle,
              ),
              TextSpan(
                text: ' ${buildInfo.displayLabel}',
                style: valueStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

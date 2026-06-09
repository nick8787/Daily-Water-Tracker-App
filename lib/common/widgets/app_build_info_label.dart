import 'package:daily_water_tracker/common/services/app_build_info.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// Installed app version label
class AppBuildInfoLabel extends StatelessWidget {
  const AppBuildInfoLabel({super.key});

  static const EdgeInsets _padding = EdgeInsets.fromLTRB(0, 16, 0, 8);

  @override
  Widget build(BuildContext context) {
    final buildInfo = GetIt.I.get<AppBuildInfo>();
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.62);

    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: textColor,
      fontSize: 12,
      letterSpacing: 0.15,
      fontWeight: FontWeight.w400,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Padding(
      padding: _padding,
      child: Center(
        child: Text(
          '${LocaleKeys.account_app_version_label.tr()} ${buildInfo.displayLabel}',
          style: style,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

import 'package:daily_water_tracker/features/theme/theme_info.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> showNotificationSettingsDialog({
  required BuildContext context,
  String? message,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      final cs = theme.colorScheme;
      const radius = 24.0;
      const btnRadius = 14.0;

      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Material(
          color: cs.surface,
          elevation: 20,
          shadowColor: Colors.black.withValues(alpha: 0.18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: BorderSide(color: cs.outline.withValues(alpha: 0.12)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: brandBlue.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_off_outlined,
                      size: 28,
                      color: brandBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  LocaleKeys.notifications_dialog_title.tr(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.35,
                    height: 1.15,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message ?? LocaleKeys.notifications_dialog_body.tr(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cs.onSurface.withValues(alpha: 0.75),
                          side: BorderSide(
                            color: cs.outline.withValues(alpha: 0.35),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(btnRadius),
                          ),
                        ),
                        child: Text(
                          LocaleKeys.notifications_dialog_not_now.tr(),
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          Navigator.of(dialogContext).pop();
                          await openAppSettings();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: brandBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(btnRadius),
                          ),
                        ),
                        child: Text(
                          LocaleKeys.notifications_dialog_open_settings.tr(),
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

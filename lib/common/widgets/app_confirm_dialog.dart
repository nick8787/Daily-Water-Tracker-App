import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:daily_water_tracker/features/theme/decorations.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

enum AppConfirmIntent {
  destructive,

  affirmative,
}

Future<bool?> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String? cancelText,
  String? confirmText,
  AppConfirmIntent intent = AppConfirmIntent.destructive,
  IconData? icon,
  Color? iconBackgroundColor,
  Color? iconForegroundColor,
  bool barrierDismissible = true,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: AppDecorations.modalBarrier(),
    builder: (dialogContext) {
      return AppConfirmDialog(
        title: title,
        message: message,
        cancelText: cancelText ?? LocaleKeys.common_cancel.tr(),
        confirmText: confirmText ?? LocaleKeys.common_delete.tr(),
        intent: intent,
        icon: icon,
        iconBackgroundColor: iconBackgroundColor,
        iconForegroundColor: iconForegroundColor,
      );
    },
  );
}

class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.cancelText,
    required this.confirmText,
    required this.intent,
    this.icon,
    this.iconBackgroundColor,
    this.iconForegroundColor,
  });

  final String title;
  final String message;
  final String cancelText;
  final String confirmText;
  final AppConfirmIntent intent;
  final IconData? icon;
  final Color? iconBackgroundColor;
  final Color? iconForegroundColor;

  static const double _kRadius = 24;
  static const double _kButtonRadius = 14;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final onVar = cs.onSurfaceVariant;

    final Color confirmBg;
    final Color confirmFg;
    switch (intent) {
      case AppConfirmIntent.destructive:
        confirmBg = cs.error;
        confirmFg = cs.onError;
      case AppConfirmIntent.affirmative:
        confirmBg = cs.primary;
        confirmFg = cs.onPrimary;
    }

    final IconData? effectiveIcon = icon;
    final Color iconBg =
        iconBackgroundColor ??
        (intent == AppConfirmIntent.destructive
            ? cs.error.withValues(alpha: 0.12)
            : cs.primary.withValues(alpha: 0.12));
    final Color iconFg =
        iconForegroundColor ??
        (intent == AppConfirmIntent.destructive ? cs.error : cs.primary);

    return Dialog(
      backgroundColor: AppDecorations.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Material(
        color: cs.surface,
        elevation: 20,
        shadowColor: AppDecorations.modalBarrier(0.18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_kRadius),
          side: BorderSide(
            color: cs.outline.withValues(alpha: 0.12),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (effectiveIcon != null) ...[
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(effectiveIcon, size: 28, color: iconFg),
                  ),
                ),
                const SizedBox(height: 18),
              ],
              Text(
                title,
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
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: onVar,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: cs.onSurface.withValues(alpha: 0.75),
                        side: BorderSide(
                          color: cs.outline.withValues(alpha: 0.35),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_kButtonRadius),
                        ),
                      ),
                      child: Text(
                        cancelText,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: confirmBg,
                        foregroundColor: confirmFg,
                        elevation: intent == AppConfirmIntent.destructive
                            ? 2
                            : 1,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_kButtonRadius),
                        ),
                        shadowColor: confirmBg.withValues(alpha: 0.4),
                      ),
                      child: Text(
                        confirmText,
                        style: const TextStyle(fontWeight: FontWeight.w800),
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
  }
}

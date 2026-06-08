import 'package:daily_water_tracker/common/assets.dart';
import 'package:daily_water_tracker/features/theme/theme_colors.dart';
import 'package:daily_water_tracker/features/vibration/vibration_feedback.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Log out and delete account actions for Settings → More.
class AccountSessionActionsFooter extends StatelessWidget {
  const AccountSessionActionsFooter({
    super.key,
    required this.actionsEnabled,
    required this.onLogOutPressed,
    required this.onDeleteAccountPressed,
  });

  final bool actionsEnabled;
  final VoidCallback onLogOutPressed;
  final VoidCallback onDeleteAccountPressed;

  static const double _buttonHeight = 50;
  static const double _gap = 10;
  static const double _radius = 16;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SessionActionButton(
            label: LocaleKeys.account_button_log_out.tr(),
            iconAsset: icAccountLogOut,
            enabled: actionsEnabled,
            onPressed: onLogOutPressed,
            style: _SessionActionButtonStyle.signOut(),
          ),
        ),
        const SizedBox(width: _gap),
        Expanded(
          child: _SessionActionButton(
            label: LocaleKeys.account_dialog_delete_confirm.tr(),
            iconAsset: icDeleteAccountRed,
            enabled: actionsEnabled,
            onPressed: onDeleteAccountPressed,
            style: _SessionActionButtonStyle.destructive(context),
          ),
        ),
      ],
    );
  }
}

class _SessionActionButtonStyle {
  const _SessionActionButtonStyle({
    required this.background,
    required this.borderColor,
    required this.foreground,
    required this.iconColor,
  });

  factory _SessionActionButtonStyle.signOut() {
    return _SessionActionButtonStyle(
      background: AppPalette.brandBlue.withValues(alpha: 0.07),
      borderColor: AppPalette.brandBlue.withValues(alpha: 0.34),
      foreground: AppPalette.brandBlue,
      iconColor: AppPalette.brandBlue,
    );
  }

  factory _SessionActionButtonStyle.destructive(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return _SessionActionButtonStyle(
      background: scheme.error.withValues(alpha: 0.08),
      borderColor: scheme.error.withValues(alpha: 0.28),
      foreground: scheme.error,
      iconColor: AppPalette.cherryRed,
    );
  }

  final Color background;
  final Color borderColor;
  final Color foreground;
  final Color iconColor;
}

class _SessionActionButton extends StatelessWidget {
  const _SessionActionButton({
    required this.label,
    required this.iconAsset,
    required this.enabled,
    required this.onPressed,
    required this.style,
  });

  final String label;
  final String iconAsset;
  final bool enabled;
  final VoidCallback onPressed;
  final _SessionActionButtonStyle style;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.1,
      color: enabled ? style.foreground : style.foreground.withValues(alpha: 0.38),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? () => VibrationFeedback.run(context, onPressed) : null,
        borderRadius: BorderRadius.circular(AccountSessionActionsFooter._radius),
        child: Ink(
          height: AccountSessionActionsFooter._buttonHeight,
          decoration: BoxDecoration(
            color: style.background,
            borderRadius: BorderRadius.circular(AccountSessionActionsFooter._radius),
            border: Border.all(
              color: enabled
                  ? style.borderColor
                  : style.borderColor.withValues(alpha: 0.35),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  iconAsset,
                  width: 18,
                  height: 18,
                  filterQuality: FilterQuality.high,
                  color: enabled
                      ? style.iconColor
                      : style.iconColor.withValues(alpha: 0.38),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: textStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

import 'package:daily_water_tracker/common/assets.dart';

class AccountLogoutFooter extends StatelessWidget {
  const AccountLogoutFooter({
    super.key,
    required this.onLogOutPressed,
    this.actionsEnabled = true,
  });

  final VoidCallback onLogOutPressed;
  final bool actionsEnabled;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final foreground = onSurface.withValues(alpha: 0.7);

    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: actionsEnabled ? onLogOutPressed : null,
        style: TextButton.styleFrom(
          foregroundColor: foreground,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: Image.asset(
          icAccountLogOut,
          width: 20,
          height: 20,
          filterQuality: FilterQuality.high,
          color: foreground,
        ),
        label: Text(
          LocaleKeys.account_button_log_out.tr(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: foreground,
          ),
        ),
      ),
    );
  }
}

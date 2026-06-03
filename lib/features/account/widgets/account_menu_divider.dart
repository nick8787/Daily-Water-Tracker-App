import 'package:flutter/material.dart';

class AccountMenuDivider extends StatelessWidget {
  const AccountMenuDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        theme.dividerTheme.color ??
        theme.colorScheme.outlineVariant.withValues(alpha: 0.85);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(height: 1, color: color),
    );
  }
}

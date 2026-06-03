import 'package:flutter/material.dart';
import 'package:daily_water_tracker/features/theme/decorations.dart';

class AuthDivider extends StatelessWidget {
  final String label;

  const AuthDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final lineColor = AppAuthStyle.dividerColor(context);
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(child: Divider(color: lineColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.65),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: lineColor)),
      ],
    );
  }
}

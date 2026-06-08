import 'package:daily_water_tracker/features/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class DebugSectionCard extends StatelessWidget {
  final Widget child;

  const DebugSectionCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: appCardDecoration(context, radius: 20),
      child: child,
    );
  }
}

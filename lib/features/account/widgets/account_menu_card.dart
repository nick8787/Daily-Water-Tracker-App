import 'package:flutter/material.dart';
import 'package:daily_water_tracker/features/theme/app_theme_extensions.dart';

class AccountMenuCard extends StatelessWidget {
  const AccountMenuCard({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: appCardDecoration(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:daily_water_tracker/features/theme/app_theme_extensions.dart';

class AccountMenuCard extends StatelessWidget {
  const AccountMenuCard({
    super.key,
    required this.children,
    this.expandVertically = false,
  });

  final List<Widget> children;
  final bool expandVertically;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: expandVertically ? double.infinity : null,
      decoration: appCardDecoration(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          mainAxisSize:
              expandVertically ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

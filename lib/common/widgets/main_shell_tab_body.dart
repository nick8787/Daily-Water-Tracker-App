import 'package:daily_water_tracker/common/widgets/app_bottom_nav_bar.dart';
import 'package:flutter/material.dart';

/// Shared body chrome for Home, Statistics, and Account main-shell tabs.
///
/// Reserves [bottomClearance] below [child] so the bottom edge of content
/// aligns on every screen size and platform.
class MainShellTabBody extends StatelessWidget {
  const MainShellTabBody({
    super.key,
    required this.child,
    this.bottomClearance,
  });

  final Widget child;

  /// When null, resolved from [AppBottomNavBar.mainShellContentBottomClearance].
  final double? bottomClearance;

  static double resolveBottomClearance(BuildContext context) =>
      AppBottomNavBar.mainShellContentBottomClearance(context);

  @override
  Widget build(BuildContext context) {
    final clearance = bottomClearance ?? resolveBottomClearance(context);

    return Column(
      children: [
        Expanded(child: child),
        SizedBox(height: clearance),
      ],
    );
  }
}

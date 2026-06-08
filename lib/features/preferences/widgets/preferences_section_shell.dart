import 'package:daily_water_tracker/common/assets.dart';
import 'package:daily_water_tracker/features/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PreferencesSectionShell extends StatelessWidget {
  const PreferencesSectionShell({
    super.key,
    required this.title,
    required this.onInfoTap,
    required this.child,
  });

  final String title;
  final VoidCallback onInfoTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: appCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onInfoTap,
                  borderRadius: BorderRadius.circular(22),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 2, 4, 8),
                    child: SvgPicture.asset(
                      icInfoSvg,
                      width: 22,
                      height: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

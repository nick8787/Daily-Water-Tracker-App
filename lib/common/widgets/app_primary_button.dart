import 'package:daily_water_tracker/features/theme/decorations.dart';
import 'package:daily_water_tracker/features/theme/theme_colors.dart';
import 'package:flutter/material.dart';

class AppGradientButton extends StatelessWidget {
  const AppGradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.busy = false,
    this.height = 54,
    this.radius = 18,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool busy;
  final double height;
  final double radius;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final canInteract = enabled && !busy;

    const gradient = AppDecorations.primaryButton;

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: Material(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          color: Colors.transparent,
          child: InkWell(
            onTap: canInteract ? onTap : null,
            child: Ink(
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                gradient: gradient,
                boxShadow: AppDecorations.primaryButtonShadow(),
              ),
              child: Center(
                child: busy
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: AppPalette.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[
                            Icon(icon, color: AppPalette.white, size: 22),
                            const SizedBox(width: 10),
                          ],
                          Flexible(
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.titleSmall?.copyWith(
                                color: AppPalette.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.05,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

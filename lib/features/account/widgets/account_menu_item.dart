import 'package:flutter/material.dart';

class AccountMenuItem extends StatelessWidget {
  const AccountMenuItem({
    super.key,
    required this.title,
    required this.onTap,
    this.leadingIcon,
    this.leadingAsset,
    this.leadingAssetColor,
    this.subtitle,
    this.trailing,
    this.showChevron = true,
    this.enabled = true,
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final String? leadingAsset;
  final Color? leadingAssetColor;
  final Widget? trailing;
  final bool showChevron;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    assert(
      (leadingIcon == null) != (leadingAsset == null),
      'Provide either leadingIcon or leadingAsset (exactly one).',
    );

    final titleStyle = Theme.of(context).textTheme.titleMedium;
    final subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      height: 1.1,
    );
    final iconColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.55);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              leadingAsset != null
                  ? Image.asset(
                      leadingAsset!,
                      width: 22,
                      height: 22,
                      filterQuality: FilterQuality.high,
                      color: leadingAssetColor ?? iconColor,
                    )
                  : Icon(leadingIcon, size: 22, color: iconColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: titleStyle),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: subtitleStyle),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
              if (trailing == null && showChevron)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 32,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.24),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

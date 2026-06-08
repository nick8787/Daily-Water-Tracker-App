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
    this.fillVertically = false,
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final String? leadingAsset;
  final Color? leadingAssetColor;
  final Widget? trailing;
  final bool showChevron;
  final bool enabled;
  final bool fillVertically;
  final VoidCallback onTap;

  static const double _leadingSize = 22;
  static const double _horizontalPadding = 16;
  static const double _verticalPadding = 12;

  Widget _buildLeading(Color iconColor) {
    final leading = leadingAsset != null
        ? Image.asset(
            leadingAsset!,
            width: _leadingSize,
            height: _leadingSize,
            filterQuality: FilterQuality.high,
            color: leadingAssetColor ?? iconColor,
          )
        : Icon(leadingIcon, size: _leadingSize, color: iconColor);

    return SizedBox(
      width: _leadingSize,
      height: _leadingSize,
      child: Center(child: leading),
    );
  }

  Widget _buildTitle(
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
  ) {
    final compactTitleStyle = titleStyle?.copyWith(height: 1.0);

    if (subtitle == null) {
      return Expanded(
        child: Text(
          title,
          style: compactTitleStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: compactTitleStyle),
          const SizedBox(height: 2),
          Text(subtitle!, style: subtitleStyle),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    Color iconColor,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
  ) {
    return Row(
      children: [
        _buildLeading(iconColor),
        const SizedBox(width: 14),
        _buildTitle(titleStyle, subtitleStyle),
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
    );
  }

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

    final row = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
        vertical: fillVertically ? 0 : _verticalPadding,
      ),
      child: _buildRow(context, iconColor, titleStyle, subtitleStyle),
    );

    final content = fillVertically
        ? SizedBox.expand(
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: double.infinity,
                child: row,
              ),
            ),
          )
        : row;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: content,
      ),
    );
  }
}

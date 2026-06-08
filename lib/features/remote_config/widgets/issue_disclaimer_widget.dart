import 'package:daily_water_tracker/features/remote_config/models/issue_disclaimer.dart';
import 'package:daily_water_tracker/features/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class IssueDisclaimerWidget extends StatelessWidget {
  const IssueDisclaimerWidget({
    super.key,
    required this.disclaimer,
    this.margin = const EdgeInsets.fromLTRB(6, 6, 6, 14),
  });

  final IssueDisclaimer disclaimer;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    final title = disclaimer.title?.trim();
    final description = disclaimer.description?.trim();
    if ((title == null || title.isEmpty) &&
        (description == null || description.isEmpty)) {
      return const SizedBox.shrink();
    }

    final palette = _paletteFor(context, disclaimer.level);

    return Container(
      margin: margin,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
        color: palette.bg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              palette.icon,
              size: 20,
              color: palette.border,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null && title.isNotEmpty)
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      color: palette.text,
                    ),
                  ),
                if (description != null && description.isNotEmpty) ...[
                  if (title != null && title.isNotEmpty)
                    const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                      color: palette.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

({Color bg, Color border, Color text, Color textMuted, IconData icon})
_paletteFor(BuildContext context, IssueDisclaimerLevel level) {
  final colors = context.appColors;
  switch (level) {
    case IssueDisclaimerLevel.warning:
      return (
        bg: colors.disclaimerWarning.bg,
        border: colors.disclaimerWarning.border,
        text: colors.disclaimerWarning.text,
        textMuted: colors.disclaimerWarning.textMuted,
        icon: Icons.warning_amber_rounded,
      );
    case IssueDisclaimerLevel.error:
      return (
        bg: colors.disclaimerError.bg,
        border: colors.disclaimerError.border,
        text: colors.disclaimerError.text,
        textMuted: colors.disclaimerError.textMuted,
        icon: Icons.error_outline_rounded,
      );
    case IssueDisclaimerLevel.neutral:
      return (
        bg: colors.disclaimerInfo.bg,
        border: colors.disclaimerInfo.border,
        text: colors.disclaimerInfo.text,
        textMuted: colors.disclaimerInfo.textMuted,
        icon: Icons.info_outline_rounded,
      );
  }
}

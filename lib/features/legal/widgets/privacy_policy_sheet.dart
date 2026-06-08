import 'package:daily_water_tracker/features/home/widgets/water_progress_indicator.dart';
import 'package:daily_water_tracker/features/theme/theme_info.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showPrivacyPolicySheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: AppDecorations.transparent,
    barrierColor: AppDecorations.modalBarrier(),
    builder: (ctx) {
      return DraggableScrollableSheet(
        initialChildSize: 0.58,
        minChildSize: 0.42,
        maxChildSize: 0.88,
        expand: false,
        builder: (context, scrollController) {
          return _PrivacyPolicySheetShell(
            scrollController: scrollController,
          );
        },
      );
    },
  );
}

class _PrivacyPolicySheetShell extends StatelessWidget {
  const _PrivacyPolicySheetShell({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    const muted = WaterProgressIndicator.labelMuted;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: Material(
        color: colors.sheetSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SheetDragHandle(),
            Divider(
              height: 1,
              thickness: 0.5,
              color: muted.withValues(alpha: 0.22),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
                child: const PrivacyPolicySheet(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrivacyPolicySheet extends StatelessWidget {
  const PrivacyPolicySheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    const graphite = WaterProgressIndicator.valueGraphite;
    const muted = WaterProgressIndicator.labelMuted;
    final tint = brandBlue.withValues(alpha: 0.14);
    final softBorder = brandBlue.withValues(alpha: 0.12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: tint,
                shape: BoxShape.circle,
                border: Border.all(color: softBorder),
              ),
              child: Icon(
                Icons.privacy_tip_outlined,
                size: 24,
                color: brandBlue.withValues(alpha: 0.92),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                LocaleKeys.legal_privacy_policy_title.tr(),
                style: theme.titleLarge?.copyWith(
                  color: graphite,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.35,
                  height: 1.12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: softBorder),
          ),
          child: Row(
            children: [
              Icon(
                Icons.update_rounded,
                size: 18,
                color: brandBlue.withValues(alpha: 0.85),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: theme.bodyMedium?.copyWith(
                      color: graphite,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text:
                            '${LocaleKeys.legal_privacy_policy_last_updated_label.tr()} ',
                      ),
                      TextSpan(
                        text: LocaleKeys.legal_privacy_policy_last_updated_date
                            .tr(),
                        style: const TextStyle(
                          color: brandBlue,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          LocaleKeys.legal_privacy_policy_intro.tr(),
          style: theme.bodyMedium?.copyWith(
            color: muted.withValues(alpha: 0.95),
            height: 1.48,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 22),
        _SectionTitle(LocaleKeys.legal_privacy_policy_section_collect.tr()),
        _Bullet(LocaleKeys.legal_privacy_policy_collect_account.tr()),
        _Bullet(LocaleKeys.legal_privacy_policy_collect_hydration.tr()),
        _Bullet(LocaleKeys.legal_privacy_policy_collect_preferences.tr()),
        _Bullet(LocaleKeys.legal_privacy_policy_collect_notifications.tr()),
        _Bullet(LocaleKeys.legal_privacy_policy_collect_diagnostics.tr()),
        const SizedBox(height: 16),
        _SectionTitle(LocaleKeys.legal_privacy_policy_section_use.tr()),
        _Bullet(LocaleKeys.legal_privacy_policy_use_sync.tr()),
        _Bullet(LocaleKeys.legal_privacy_policy_use_reminders.tr()),
        _Bullet(LocaleKeys.legal_privacy_policy_use_insights.tr()),
        _Bullet(LocaleKeys.legal_privacy_policy_use_improve.tr()),
        const SizedBox(height: 16),
        _SectionTitle(LocaleKeys.legal_privacy_policy_section_sharing.tr()),
        _Bullet(LocaleKeys.legal_privacy_policy_sharing_processors.tr()),
        _Bullet(LocaleKeys.legal_privacy_policy_sharing_no_sell.tr()),
        const SizedBox(height: 16),
        _SectionTitle(LocaleKeys.legal_privacy_policy_section_rights.tr()),
        _Bullet(LocaleKeys.legal_privacy_policy_rights_delete.tr()),
        _Bullet(LocaleKeys.legal_privacy_policy_rights_contact.tr()),
        const SizedBox(height: 16),
        _SectionTitle(LocaleKeys.legal_privacy_policy_section_contact.tr()),
        const SizedBox(height: 10),
        Text(
          LocaleKeys.legal_privacy_policy_contact_body.tr(),
          style: theme.bodyMedium?.copyWith(
            color: graphite,
            height: 1.45,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        _ContactEmailLink(
          email: LocaleKeys.legal_privacy_policy_contact_email.tr(),
        ),
      ],
    );
  }
}

class _SheetDragHandle extends StatelessWidget {
  const _SheetDragHandle();

  @override
  Widget build(BuildContext context) {
    const muted = WaterProgressIndicator.labelMuted;
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 8),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: muted.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: brandBlue.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: WaterProgressIndicator.valueGraphite,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: brandBlue.withValues(alpha: 0.75),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: WaterProgressIndicator.valueGraphite,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactEmailLink extends StatelessWidget {
  const _ContactEmailLink({required this.email});

  final String email;

  Future<void> _openMail(BuildContext context) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(email)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tint = brandBlue.withValues(alpha: 0.1);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openMail(context),
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: brandBlue.withValues(alpha: 0.14),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.mail_outline_rounded,
                  size: 20,
                  color: brandBlue.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: brandBlue,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 16,
                  color: brandBlue.withValues(alpha: 0.55),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

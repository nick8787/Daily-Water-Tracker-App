import 'package:daily_water_tracker/features/profile/widgets/profile_section_card.dart';
import 'package:daily_water_tracker/features/profile/widgets/profile_text_field.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ProfilePersonalDetailsSection extends StatelessWidget {
  const ProfilePersonalDetailsSection({
    super.key,
    required this.formKey,
    required this.autovalidateMode,
    required this.fullName,
    required this.email,
    required this.fullNameFocus,
    required this.onFullNameChanged,
    required this.onFullNameSubmitted,
  });

  final GlobalKey<FormState> formKey;
  final AutovalidateMode autovalidateMode;
  final TextEditingController fullName;
  final TextEditingController email;
  final FocusNode fullNameFocus;
  final VoidCallback onFullNameChanged;
  final void Function(String) onFullNameSubmitted;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: LocaleKeys.profile_section_personal.tr(),
      child: Form(
        key: formKey,
        autovalidateMode: autovalidateMode,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileTextField(
              controller: fullName,
              focusNode: fullNameFocus,
              label: LocaleKeys.profile_field_full_name.tr(),
              textInputAction: TextInputAction.next,
              reserveBottomSlot: true,
              onChanged: (_) => onFullNameChanged(),
              onFieldSubmitted: onFullNameSubmitted,
              validator: (v) {
                if ((v ?? '').trim().isEmpty) return LocaleKeys.profile_validation_required.tr();
                return null;
              },
            ),
            const SizedBox(height: 12),
            ProfileTextField(
              controller: email,
              label: LocaleKeys.profile_field_email.tr(),
              readOnly: true,
              enabled: false,
              prefixIcon: Icons.mail_outline,
            ),
          ],
        ),
      ),
    );
  }
}

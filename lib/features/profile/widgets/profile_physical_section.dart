import 'package:daily_water_tracker/features/profile/models/profile_gender.dart';
import 'package:daily_water_tracker/features/profile/widgets/profile_gender_field.dart';
import 'package:daily_water_tracker/features/profile/widgets/profile_section_card.dart';
import 'package:daily_water_tracker/features/profile/widgets/profile_text_field.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ProfilePhysicalSection extends StatelessWidget {
  const ProfilePhysicalSection({
    super.key,
    required this.weightController,
    required this.weightFocus,
    required this.gender,
    required this.onWeightChanged,
    required this.onGenderChanged,
  });

  final TextEditingController weightController;
  final FocusNode weightFocus;
  final ProfileGender? gender;
  final VoidCallback onWeightChanged;
  final ValueChanged<ProfileGender?> onGenderChanged;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: LocaleKeys.profile_section_physical.tr(),
      child: Column(
        children: [
          ProfileTextField(
            controller: weightController,
            focusNode: weightFocus,
            label: LocaleKeys.profile_field_weight.tr(),
            keyboardType: TextInputType.number,
            prefixIcon: Icons.monitor_weight_outlined,
            reserveBottomSlot: true,
            onChanged: (_) => onWeightChanged(),
            validator: (v) {
              final value = (v ?? '').trim();
              if (value.isEmpty) return null;
              final parsed = int.tryParse(value);
              if (parsed == null) return LocaleKeys.profile_validation_weight_invalid.tr();
              if (parsed <= 0) return '> 0';
              if (parsed > 600) return LocaleKeys.profile_validation_weight_too_large.tr();
              return null;
            },
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              LocaleKeys.profile_tip_auto_goal.tr(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ProfileGenderField(
            value: gender,
            onChanged: onGenderChanged,
          ),
        ],
      ),
    );
  }
}

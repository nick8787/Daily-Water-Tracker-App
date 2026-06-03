import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_water_tracker/common/l10n/profile_gender_l10n.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

import 'package:daily_water_tracker/features/profile/models/profile_gender.dart';
import 'package:daily_water_tracker/features/profile/widgets/profile_text_field.dart'
    show profileFieldHintColor;
import 'package:daily_water_tracker/features/theme/theme_info.dart';

class ProfileGenderField extends StatelessWidget {
  const ProfileGenderField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ProfileGender? value;
  final ValueChanged<ProfileGender?> onChanged;

  @override
  Widget build(BuildContext context) {
    final hintColor = profileFieldHintColor(context);
    final labelBaseStyle = TextStyle(
      color: hintColor,
      fontWeight: FontWeight.w500,
      fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize ?? 16,
      height: 1.2,
    );
    final floatingLabelStyle = WidgetStateTextStyle.resolveWith((states) {
      if (states.contains(WidgetState.focused)) {
        return const TextStyle(color: brandBlue, fontWeight: FontWeight.w600);
      }
      return TextStyle(color: hintColor, fontWeight: FontWeight.w500);
    });

    return InputDecorator(
      decoration: InputDecoration(
        label: Text(LocaleKeys.profile_field_gender.tr(), style: labelBaseStyle),
        floatingLabelStyle: floatingLabelStyle,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.85),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: brandBlue, width: 1.4),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ProfileGender>(
          value: value,
          isExpanded: true,
          hint: Text(
            LocaleKeys.profile_gender_select.tr(),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: hintColor,
              fontWeight: FontWeight.w400,
            ),
          ),
          isDense: true,
          items: ProfileGender.values
              .map(
                (g) => DropdownMenuItem(
                  value: g,
                  child: Text(g.localizedLabel),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

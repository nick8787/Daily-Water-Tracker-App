import 'package:flutter/material.dart';
import 'package:daily_water_tracker/features/theme/theme_info.dart';

Color profileFieldHintColor(BuildContext context) {
  return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
}

class ProfileTextField extends StatelessWidget {
  const ProfileTextField({
    super.key,
    required this.controller,
    required this.label,
    this.readOnly = false,
    this.enabled = true,
    this.reserveBottomSlot = false,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.focusNode,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final bool readOnly;
  final bool enabled;
  final bool reserveBottomSlot;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hintColor = profileFieldHintColor(context);
    final labelBaseStyle = TextStyle(
      color: hintColor,
      fontWeight: FontWeight.w500,
      fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize ?? 16,
      height: 1.2,
    );
    final slotStyle = TextStyle(
      fontSize: 12,
      height: 1.32,
      color: reserveBottomSlot ? Colors.transparent : null,
    );
    final errorStyle = TextStyle(
      fontSize: 12,
      height: 1.32,
      color: scheme.error,
    );

    final floatingLabelStyle = WidgetStateTextStyle.resolveWith((states) {
      if (!enabled) {
        return TextStyle(
          color: scheme.onSurface.withValues(alpha: 0.38),
          fontWeight: FontWeight.w500,
        );
      }
      if (states.contains(WidgetState.error)) {
        return TextStyle(color: scheme.error, fontWeight: FontWeight.w600);
      }
      if (states.contains(WidgetState.focused)) {
        return const TextStyle(color: brandBlue, fontWeight: FontWeight.w600);
      }
      return TextStyle(color: hintColor, fontWeight: FontWeight.w500);
    });

    final prefixColor = WidgetStateColor.resolveWith((states) {
      if (!enabled) {
        return scheme.onSurface.withValues(alpha: 0.38);
      }
      if (states.contains(WidgetState.error)) {
        return scheme.error;
      }
      if (states.contains(WidgetState.focused)) {
        return brandBlue;
      }
      return hintColor;
    });

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      readOnly: readOnly,
      enabled: enabled,
      enableInteractiveSelection: enabled && !readOnly,
      showCursor: enabled && !readOnly,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      decoration: InputDecoration(
        label: Text(label, style: labelBaseStyle),
        floatingLabelStyle: floatingLabelStyle,
        helperText: reserveBottomSlot ? '\u00A0' : null,
        helperStyle: reserveBottomSlot ? slotStyle : null,
        helperMaxLines: reserveBottomSlot ? 2 : null,
        errorStyle: reserveBottomSlot ? errorStyle : null,
        errorMaxLines: reserveBottomSlot ? 2 : null,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        prefixIconColor: prefixIcon == null ? null : prefixColor,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1.2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1.4,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }
}

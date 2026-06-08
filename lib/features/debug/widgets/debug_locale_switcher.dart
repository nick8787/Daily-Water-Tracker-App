import 'package:daily_water_tracker/features/locale/cubit/locale_cubit.dart';
import 'package:daily_water_tracker/features/locale/cubit/locale_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Compact EN / UK / SYS toggles for in-app locale QA (no app restart).
class DebugLocaleSwitcher extends StatelessWidget {
  const DebugLocaleSwitcher({super.key});

  static const double _chipGap = 6;
  static const double _trailingInset = 16;

  @override
  Widget build(BuildContext context) {
    final preference = context.select(
      (LocaleCubit c) => c.state.preference,
    );
    final cubit = context.read<LocaleCubit>();

    return Padding(
      padding: const EdgeInsets.only(right: _trailingInset),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Chip(
            label: 'EN',
            selected: preference == AppLocalePreference.english,
            onTap: cubit.useEnglish,
          ),
          const SizedBox(width: _chipGap),
          _Chip(
            label: 'UK',
            selected: preference == AppLocalePreference.ukrainian,
            onTap: cubit.useUkrainian,
          ),
          const SizedBox(width: _chipGap),
          _Chip(
            label: 'SYS',
            selected: preference == AppLocalePreference.system,
            onTap: cubit.useSystemLocale,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? scheme.primary.withValues(alpha: 0.14)
          : scheme.surfaceContainerHighest.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

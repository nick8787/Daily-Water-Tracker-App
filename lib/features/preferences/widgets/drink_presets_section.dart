import 'package:daily_water_tracker/features/preferences/cubit/preferences_cubit.dart';
import 'package:daily_water_tracker/features/preferences/cubit/preferences_state.dart';
import 'package:daily_water_tracker/features/preferences/widgets/info_sheets/presets_info_sheet.dart';
import 'package:daily_water_tracker/features/preferences/widgets/preferences_info_bottom_sheet.dart';
import 'package:daily_water_tracker/features/preferences/widgets/preferences_section_shell.dart';
import 'package:daily_water_tracker/features/theme/decorations.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DrinkPresetsSection extends StatefulWidget {
  const DrinkPresetsSection({super.key});

  @override
  State<DrinkPresetsSection> createState() => _DrinkPresetsSectionState();
}

class _DrinkPresetsSectionState extends State<DrinkPresetsSection> {
  late final List<TextEditingController> _controllers;
  bool _didInitialSync = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncControllers(List<int> values) {
    for (var i = 0; i < 3; i++) {
      final t = '${values[i]}';
      if (_controllers[i].text != t) {
        _controllers[i].text = t;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<PreferencesCubit, PreferencesState>(
      listenWhen: (previous, current) {
        if (current is! PreferencesLoaded) return false;
        return !current.presetsDraftDirty;
      },
      listener: (context, state) {
        if (state is PreferencesLoaded) {
          _syncControllers(state.drinkPresetsDraft);
        }
      },
      builder: (context, state) {
        if (state is! PreferencesLoaded) {
          return const SizedBox.shrink();
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (!_didInitialSync) {
            _syncControllers(state.drinkPresetsDraft);
            _didInitialSync = true;
          }
        });

        void onFieldChanged(int index, String value) {
          context.read<PreferencesCubit>().setDrinkPreset(index, value);
        }

        return PreferencesSectionShell(
          title: LocaleKeys.preferences_section_presets.tr(),
          onInfoTap: () => showPreferencesInfoSheet(
            context,
            body: const PresetsInfoSheet(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                LocaleKeys.preferences_presets_hint.tr(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _controllers[i],
                        keyboardType: TextInputType.number,
                        textInputAction: i < 2
                            ? TextInputAction.next
                            : TextInputAction.done,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(5),
                        ],
                        decoration: InputDecoration(
                          isDense: true,
                          suffixText: 'ml',
                          suffixStyle: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.45,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          filled: true,
                          fillColor: AppFieldStyle.fillColor(context),
                          border: AppFieldStyle.borderNone(AppFieldStyle.radius14),
                          enabledBorder: AppFieldStyle.borderEnabled(
                            AppFieldStyle.radius14,
                          ),
                          focusedBorder: AppFieldStyle.borderFocused(
                            radius: AppFieldStyle.radius14,
                          ),
                        ),
                        onChanged: (v) => onFieldChanged(i, v),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:daily_water_tracker/common/l10n/locale_resolver.dart';
import 'package:daily_water_tracker/common/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'locale_state.dart';

/// Drives [EasyLocalization] locale: system (device) or debug override.
class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit()
    : super(
        LocaleState(
          preference: AppLocalePreference.system,
          effectiveLocale: LocaleResolver.resolveFromPlatform(),
        ),
      );

  void onSystemLocaleChanged(Locale? platformLocale) {
    if (state.preference != AppLocalePreference.system) return;
    final next = LocaleResolver.resolve(platformLocale);
    if (next == state.effectiveLocale) return;
    emit(state.copyWith(effectiveLocale: next));
  }

  void useSystemLocale() => _applyPreference(AppLocalePreference.system);

  void useEnglish() => _applyPreference(AppLocalePreference.english);

  void useUkrainian() => _applyPreference(AppLocalePreference.ukrainian);

  void _applyPreference(AppLocalePreference preference) {
    final effective = switch (preference) {
      AppLocalePreference.system => LocaleResolver.resolveFromPlatform(),
      AppLocalePreference.english => LocalizationService.englishLocale,
      AppLocalePreference.ukrainian => LocalizationService.ukrainianLocale,
    };
    emit(
      LocaleState(
        preference: preference,
        effectiveLocale: effective,
      ),
    );
  }
}

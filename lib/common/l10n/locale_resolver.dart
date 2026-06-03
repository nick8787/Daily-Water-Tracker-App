import 'package:flutter/material.dart';

import '../services/localization_service.dart';

/// Maps device / platform locale to a supported app locale (en or uk).
/// Any unsupported language falls back to English.
class LocaleResolver {
  LocaleResolver._();

  static Locale resolve(Locale? platformLocale) {
    final code = (platformLocale?.languageCode ?? '').toLowerCase();
    if (code == 'uk') {
      return LocalizationService.ukrainianLocale;
    }
    return LocalizationService.englishLocale;
  }

  static Locale resolveFromPlatform() {
    return resolve(
      WidgetsBinding.instance.platformDispatcher.locale,
    );
  }
}

// ignore_for_file: avoid_classes_with_only_static_members

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LocalizationService {
  static const String translationsFolderPath = 'assets/i18n';

  static const Locale englishLocale = Locale('en', 'US');
  static const Locale ukrainianLocale = Locale('uk', 'UA');

  static const List<Locale> supportedLocales = [
    englishLocale,
    ukrainianLocale,
  ];

  Future<void> initialize() async {
    await EasyLocalization.ensureInitialized();
  }
}

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum AppLocalePreference {
  /// Follow device language (uk → Ukrainian, otherwise English).
  system,

  english,
  ukrainian,
}

class LocaleState extends Equatable {
  const LocaleState({
    required this.preference,
    required this.effectiveLocale,
  });

  final AppLocalePreference preference;
  final Locale effectiveLocale;

  LocaleState copyWith({
    AppLocalePreference? preference,
    Locale? effectiveLocale,
  }) {
    return LocaleState(
      preference: preference ?? this.preference,
      effectiveLocale: effectiveLocale ?? this.effectiveLocale,
    );
  }

  @override
  List<Object?> get props => [preference, effectiveLocale];
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_water_tracker/features/locale/cubit/locale_cubit.dart';
import 'package:daily_water_tracker/features/locale/cubit/locale_state.dart';
import 'package:daily_water_tracker/features/theme/text_styles.dart';

class AppScreenTitle extends StatelessWidget {
  const AppScreenTitle({
    super.key,
    required this.title,
    this.centered = false,
  });

  final String title;
  final bool centered;

  /// Screen header typography (Account body title, pushed-route AppBar titles).
  static TextStyle? headerStyle(BuildContext context) {
    final theme = Theme.of(context);
    return AppTypography.screenHeader(
      theme.textTheme,
      theme.colorScheme.onSurface,
    );
  }

  /// In-body title that refreshes when [LocaleCubit] changes (Statistics, Account).
  static Widget localized({
    Key? key,
    required String localeKey,
    bool centered = false,
  }) {
    return _LocaleAwareScreenTitle(
      key: key,
      localeKey: localeKey,
      centered: centered,
    );
  }

  /// [AppBar] title matching [headerStyle], with locale refresh on switch.
  static Widget appBarLocalized({
    required String localeKey,
  }) {
    return _LocaleAwareAppBarTitle(localeKey: localeKey);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Align(
        alignment: centered ? Alignment.center : Alignment.centerLeft,
        child: Text(
          title,
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: headerStyle(context),
        ),
      ),
    );
  }
}

class _LocaleAwareScreenTitle extends StatelessWidget {
  const _LocaleAwareScreenTitle({
    super.key,
    required this.localeKey,
    required this.centered,
  });

  final String localeKey;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      buildWhen: (prev, next) => prev.effectiveLocale != next.effectiveLocale,
      builder: (context, state) {
        return AppScreenTitle(
          title: context.tr(localeKey),
          centered: centered,
        );
      },
    );
  }
}

class _LocaleAwareAppBarTitle extends StatelessWidget {
  const _LocaleAwareAppBarTitle({required this.localeKey});

  final String localeKey;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      buildWhen: (prev, next) => prev.effectiveLocale != next.effectiveLocale,
      builder: (context, state) {
        return Text(
          context.tr(localeKey),
          style: AppScreenTitle.headerStyle(context),
        );
      },
    );
  }
}

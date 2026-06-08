import 'package:daily_water_tracker/features/theme/text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

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

  /// In-body title (Statistics, Account sections).
  static Widget localized({
    Key? key,
    required String localeKey,
    bool centered = false,
  }) {
    return _LocalizedScreenTitle(
      key: key,
      localeKey: localeKey,
      centered: centered,
    );
  }

  /// [AppBar] title matching [headerStyle].
  static Widget appBarLocalized({
    required String localeKey,
  }) {
    return _LocalizedAppBarTitle(localeKey: localeKey);
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

class _LocalizedScreenTitle extends StatelessWidget {
  const _LocalizedScreenTitle({
    super.key,
    required this.localeKey,
    required this.centered,
  });

  final String localeKey;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return AppScreenTitle(
      title: context.tr(localeKey),
      centered: centered,
    );
  }
}

class _LocalizedAppBarTitle extends StatelessWidget {
  const _LocalizedAppBarTitle({required this.localeKey});

  final String localeKey;

  @override
  Widget build(BuildContext context) {
    return Text(
      context.tr(localeKey),
      style: AppScreenTitle.headerStyle(context),
    );
  }
}

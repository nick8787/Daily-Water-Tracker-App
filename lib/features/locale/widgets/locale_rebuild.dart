import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Rebuilds a localized UI subtree when [EasyLocalization] locale changes.
///
/// Uses a scoped [KeyedSubtree] so translations refresh without tearing down
/// [MaterialApp], routes, or blocs registered above this widget.
class LocaleRebuild extends StatelessWidget {
  const LocaleRebuild({super.key, required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: ValueKey<String>('locale-ui-${context.locale.toLanguageTag()}'),
      child: builder(context),
    );
  }
}

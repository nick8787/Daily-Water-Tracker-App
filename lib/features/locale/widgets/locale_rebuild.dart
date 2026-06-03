import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_water_tracker/features/locale/cubit/locale_cubit.dart';
import 'package:daily_water_tracker/features/locale/cubit/locale_state.dart';

/// Rebuilds a localized UI subtree when locale changes.
///
/// Uses a scoped [KeyedSubtree] so translations refresh without tearing down
/// [MaterialApp], routes, or blocs registered above this widget.
class LocaleRebuild extends StatelessWidget {
  const LocaleRebuild({super.key, required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      buildWhen: (prev, next) => prev.effectiveLocale != next.effectiveLocale,
      builder: (context, state) {
        return KeyedSubtree(
          key: ValueKey<String>(
            'locale-ui-${state.effectiveLocale.toLanguageTag()}',
          ),
          child: builder(context),
        );
      },
    );
  }
}

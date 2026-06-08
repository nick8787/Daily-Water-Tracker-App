import 'dart:async';

import 'package:daily_water_tracker/features/locale/cubit/locale_cubit.dart';
import 'package:daily_water_tracker/features/locale/cubit/locale_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Keeps [EasyLocalization] in sync with [LocaleCubit] (no full-tree teardown).
class LocaleListener extends StatefulWidget {
  const LocaleListener({super.key, required this.child});

  final Widget child;

  @override
  State<LocaleListener> createState() => _LocaleListenerState();
}

class _LocaleListenerState extends State<LocaleListener>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncFromCubit());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    final platform = locales?.isNotEmpty == true
        ? locales!.first
        : WidgetsBinding.instance.platformDispatcher.locale;
    context.read<LocaleCubit>().onSystemLocaleChanged(platform);
  }

  Future<void> _syncFromCubit() async {
    if (!mounted) return;
    await _applyLocale(context.read<LocaleCubit>().state.effectiveLocale);
  }

  Future<void> _applyLocale(Locale locale) async {
    if (!mounted) return;
    if (context.locale == locale) return;
    await context.setLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocaleCubit, LocaleState>(
      listenWhen: (prev, next) => prev.effectiveLocale != next.effectiveLocale,
      listener: (context, state) {
        unawaited(_applyLocale(state.effectiveLocale));
      },
      child: widget.child,
    );
  }
}

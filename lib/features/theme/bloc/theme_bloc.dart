import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../common/services/services.dart';
import '../../../common/utils/utils.dart';
import '../app_theme.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final Box<dynamic> _themeBox;

  ThemeBloc(this._themeBox) : super(ThemeState.initial()) {
    on<SetTheme>((SetTheme event, Emitter<ThemeState> emit) async {
      emit(state.copyWith(themeMode: event.themeMode));
      await _themeBox.put(
        ThemeBox.themeModeKey,
        EnumToString().parse(event.themeMode),
      );
    });

    on<InitTheme>((InitTheme event, Emitter<ThemeState> emit) async {
      ThemeMode? themeMode = EnumToString().fromString(
        ThemeMode.values,
        _themeBox.get(ThemeBox.themeModeKey),
      );
      themeMode ??= ThemeMode.system;
      emit(state.copyWith(themeMode: themeMode));
      await _themeBox.put(
        ThemeBox.themeModeKey,
        EnumToString().parse(themeMode),
      );
    });
  }

  void switchTheme() {
    final platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isEffectivelyDark = switch (state.themeMode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => platformBrightness == Brightness.dark,
    };
    add(SetTheme(isEffectivelyDark ? ThemeMode.light : ThemeMode.dark));
  }

  void setDarkThemeEnabled(bool enabled) {
    add(SetTheme(enabled ? ThemeMode.dark : ThemeMode.light));
  }

  String get themeLabel {
    switch (state.themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}

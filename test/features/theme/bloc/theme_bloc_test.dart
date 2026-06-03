import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:daily_water_tracker/common/services/theme_box.dart';
import 'package:daily_water_tracker/common/utils/app_utils.dart';
import 'package:daily_water_tracker/features/theme/theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'theme_bloc_test.mocks.dart';

@GenerateMocks([
  Box,
])
void main() {
  final box = MockBox<dynamic>();

  const themeMode = ThemeMode.dark;
  const setThemeEvent = SetTheme(themeMode);
  const initThemeEvent = InitTheme();
  final themeModeString = EnumToString().parse(setThemeEvent.themeMode);

  group('$ThemeBloc test', () {
    blocTest<ThemeBloc, ThemeState>(
      '''
      WHEN $SetTheme is added 
      THEN box.put is called
      AND proper state is emmitted''',
      setUp: () {
        when(
          box.put(ThemeBox.themeModeKey, themeModeString),
        ).thenAnswer(
          (_) => Future.value(),
        );
      },
      build: () => ThemeBloc(box),
      verify: (_) => verify(
        box.put(ThemeBox.themeModeKey, themeModeString),
      ).called(1),
      act: (bloc) => bloc.add(setThemeEvent),
      expect: () => [
        ThemeState.initial().copyWith(themeMode: themeMode),
      ],
    );

    blocTest<ThemeBloc, ThemeState>(
      '''
      WHEN $InitTheme is added 
      THEN box.get is called
      AND proper state is emmitted''',
      setUp: () {
        when(
          box.get(ThemeBox.themeModeKey),
        ).thenReturn(EnumToString().parse(themeMode));
        when(
          box.put(ThemeBox.themeModeKey, themeModeString),
        ).thenAnswer(
          (_) => Future.value(),
        );
      },
      build: () => ThemeBloc(box),
      verify: (_) => verify(box.get(ThemeBox.themeModeKey)).called(1),
      act: (bloc) => bloc.add(initThemeEvent),
      expect: () => [
        ThemeState.initial().copyWith(themeMode: themeMode),
      ],
    );
  });
}

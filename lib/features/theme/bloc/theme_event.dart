part of 'theme_bloc.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class SetTheme extends ThemeEvent {
  final ThemeMode themeMode;

  const SetTheme(this.themeMode);

  @override
  List<Object> get props => [themeMode];
}

class InitTheme extends ThemeEvent {
  const InitTheme();

  @override
  List<Object> get props => [];
}

part of 'theme_cubit.dart';

abstract class ThemeState {}

class ThemeInitial extends ThemeState {}

class ThemeLoading extends ThemeState {}

class ThemeLoaded extends ThemeState {
  final ThemeModel theme;

  ThemeLoaded(this.theme);
}

class ThemesLoaded extends ThemeState {
  final List<ThemeModel> themes;

  ThemesLoaded(this.themes);
}

class ThemeError extends ThemeState {
  final String message;

  ThemeError(this.message);
}

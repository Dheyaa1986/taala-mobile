part of 'theme_cubit.dart';

abstract class ThemeState {}

class ThemeInitial extends ThemeState {}

class ThemeLoading extends ThemeState {}

class ThemeLoaded extends ThemeState {
  final ThemeModel theme;

  ThemeLoaded(this.theme);
}

class ThemeError extends ThemeState {
  final String message;

  ThemeError(this.message);
}

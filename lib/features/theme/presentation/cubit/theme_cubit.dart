import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/theme_model.dart';
import '../../data/repositories/theme_repository.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final ThemeRepository themeRepository;

  ThemeCubit(this.themeRepository) : super(ThemeInitial());

  Future<void> loadActiveTheme() async {
    emit(ThemeLoading());
    final result = await themeRepository.getActiveTheme();
    result.fold(
      (error) => emit(ThemeError(error.message)),
      (theme) => emit(ThemeLoaded(theme)),
    );
  }

  Future<void> loadAllThemes() async {
    emit(ThemeLoading());
    final result = await themeRepository.getAllThemes();
    result.fold(
      (error) => emit(ThemeError(error.message)),
      (themes) => emit(ThemesLoaded(themes)),
    );
  }
}

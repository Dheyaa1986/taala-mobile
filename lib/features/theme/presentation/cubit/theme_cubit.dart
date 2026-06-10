import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/themes/theme.dart';
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
      (_) => emit(ThemeInitial()),
      (theme) {
        if (theme == null) {
          TariqyAppTheme.activeTheme = null;
          emit(ThemeInitial());
          return;
        }
        TariqyAppTheme.activeTheme = theme;
        emit(ThemeLoaded(theme));
      },
    );
  }
}

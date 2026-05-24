import 'package:bloc/bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:meta/meta.dart';

part 'bottom_navigation_state.dart';

class BottomNavigationCubit extends Cubit<BottomNavigationState> {
  BottomNavigationCubit() : super(BottomNavigationInitial());

  bool viewAllArticles = false;
  StatefulNavigationShell? navigationShell;

  void goToBranch(int index) {
    if (navigationShell != null) {
      navigationShell!.goBranch(index);
      emit(ChangeBottomNavigationBranch(index));
    }
  }

  bool isProvider = true;
}

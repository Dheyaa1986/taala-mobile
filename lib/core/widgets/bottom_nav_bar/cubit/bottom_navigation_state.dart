part of 'bottom_navigation_cubit.dart';

@immutable
sealed class BottomNavigationState {}

final class BottomNavigationInitial extends BottomNavigationState {}

final class ChangeBottomNavigationBranch extends BottomNavigationState {
  final int index;

  ChangeBottomNavigationBranch(this.index);
}
